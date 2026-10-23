type 'peer query_peers = Vertex.t -> 'peer list -> bool list Lwt.t

let validate dag (vertex : Vertex.t) =
  let is_known identifier = Option.is_some (Ledger.get_vertex dag identifier) in
  if
    vertex.identifier
    <> Vertex.compute_identifier ~parents:vertex.parents
         ~transactions:vertex.transactions
  then Error "vertex identifier does not match its contents"
  else if vertex.parents = [] then Error "vertex must have at least one parent"
  else if not (List.for_all is_known vertex.parents) then
    Error "vertex has an unknown parent"
  else if vertex.transactions = [] then
    Error "vertex must contain at least one transaction"
  else if not (List.for_all Transaction.verify vertex.transactions) then
    Error "vertex contains a transaction with an invalid signature"
  else Ok ()

let register_transaction (dag : Ledger.dag) (transaction : Transaction.t) =
  match Hashtbl.find_opt dag.conflict_sets transaction.conflict_key with
  | None ->
      Hashtbl.replace dag.conflict_sets transaction.conflict_key
        {
          members = [ transaction.identifier ];
          preferred = transaction.identifier;
          last = transaction.identifier;
          count = 0;
        }
  | Some conflict_set ->
      if not (List.mem transaction.identifier conflict_set.members) then
        conflict_set.members <-
          conflict_set.members @ [ transaction.identifier ]

let add_vertex dag (vertex : Vertex.t) =
  if Option.is_some (Ledger.get_vertex dag vertex.identifier) then Ok ()
  else
    match validate dag vertex with
    | Error message -> Error message
    | Ok () ->
        Ledger.add_vertex dag vertex;
        List.iter (register_transaction dag) vertex.transactions;
        Ok ()

let preferred_transaction (dag : Ledger.dag) ~conflict_key =
  Option.map
    (fun (conflict_set : Ledger.conflict_set) -> conflict_set.preferred)
    (Hashtbl.find_opt dag.conflict_sets conflict_key)

let confidence = Ledger.confidence

let lineage dag (vertex : Vertex.t) =
  let ancestors = ref [] in
  Ledger.traverse_ancestors dag vertex (fun vertex_state ->
      ancestors := vertex_state.vertex :: !ancestors);
  vertex :: !ancestors

let lineage_transactions dag vertex =
  List.concat_map
    (fun (vertex : Vertex.t) -> vertex.transactions)
    (lineage dag vertex)

let is_preferred dag (transaction : Transaction.t) =
  preferred_transaction dag ~conflict_key:transaction.conflict_key
  = Some transaction.identifier

let is_strongly_preferred dag vertex =
  List.for_all (is_preferred dag) (lineage_transactions dag vertex)

let respond dag vertex =
  match add_vertex dag vertex with
  | Error _ -> false
  | Ok () -> is_strongly_preferred dag vertex

let sample_peers random sample_size peers =
  let candidates = Array.of_list peers in
  let candidate_count = Array.length candidates in
  for index = candidate_count - 1 downto 1 do
    let swap_index = Random.State.int random (index + 1) in
    let candidate = candidates.(index) in
    candidates.(index) <- candidates.(swap_index);
    candidates.(swap_index) <- candidate
  done;
  Array.to_list (Array.sub candidates 0 (min sample_size candidate_count))

let has_quorum (configuration : Configuration.t) votes =
  List.length (List.filter Fun.id votes) >= configuration.quorum_size

let update_preference (dag : Ledger.dag) (transaction : Transaction.t) =
  match Hashtbl.find_opt dag.conflict_sets transaction.conflict_key with
  | None -> ()
  | Some conflict_set ->
      if
        confidence dag transaction.identifier
        > confidence dag conflict_set.preferred
      then conflict_set.preferred <- transaction.identifier;
      if conflict_set.preferred <> conflict_set.last then (
        conflict_set.last <- conflict_set.preferred;
        conflict_set.count <- 1)
      else conflict_set.count <- conflict_set.count + 1

let record_success dag (vertex_state : Ledger.vertex_state) =
  vertex_state.chit <- true;
  let transactions = lineage_transactions dag vertex_state.vertex in
  List.iter
    (fun (transaction : Transaction.t) ->
      Ledger.increment_confidence dag transaction.identifier)
    transactions;
  List.iter (update_preference dag) transactions

let record_failure (dag : Ledger.dag) (vertex : Vertex.t) =
  List.iter
    (fun (transaction : Transaction.t) ->
      Option.iter
        (fun (conflict_set : Ledger.conflict_set) -> conflict_set.count <- 0)
        (Hashtbl.find_opt dag.conflict_sets transaction.conflict_key))
    vertex.transactions

let run_query_round configuration random dag query_peers peers
    (vertex : Vertex.t) =
  match Ledger.get_vertex dag vertex.identifier with
  | None -> Lwt.return_unit
  | Some vertex_state when vertex_state.queried -> Lwt.return_unit
  | Some vertex_state ->
      vertex_state.queried <- true;
      let sample =
        sample_peers random configuration.Configuration.sample_size peers
      in
      Lwt.map
        (fun votes ->
          if has_quorum configuration votes then record_success dag vertex_state
          else record_failure dag vertex)
        (query_peers vertex sample)

let pending_queries (dag : Ledger.dag) =
  Hashtbl.fold
    (fun identifier (vertex_state : Ledger.vertex_state) pending ->
      if vertex_state.queried || identifier = Vertex.genesis.identifier then
        pending
      else vertex_state.vertex :: pending)
    dag.vertices []
  |> List.sort (fun (left : Vertex.t) (right : Vertex.t) ->
      String.compare left.identifier right.identifier)

let satisfies_decision_rule (configuration : Configuration.t) dag
    (transaction : Transaction.t) =
  match Hashtbl.find_opt dag.Ledger.conflict_sets transaction.conflict_key with
  | None -> false
  | Some conflict_set ->
      conflict_set.members = [ transaction.identifier ]
      && confidence dag transaction.identifier
         >= configuration.decision_threshold
      || conflict_set.preferred = transaction.identifier
         && conflict_set.count >= configuration.decision_threshold

let is_accepted configuration (dag : Ledger.dag) transaction_identifier =
  let evaluated = Hashtbl.create 16 in
  let rec transaction_accepted identifier =
    if Hashtbl.mem dag.accepted identifier then true
    else
      match Hashtbl.find_opt evaluated identifier with
      | Some result -> result
      | None ->
          Hashtbl.replace evaluated identifier false;
          let result =
            match Ledger.find_transaction dag identifier with
            | None -> false
            | Some (transaction, vertex) ->
                List.for_all vertex_accepted vertex.parents
                && satisfies_decision_rule configuration dag transaction
          in
          Hashtbl.replace evaluated identifier result;
          if result then Hashtbl.replace dag.accepted identifier true;
          result
  and vertex_accepted vertex_identifier =
    match Ledger.get_vertex dag vertex_identifier with
    | None -> false
    | Some vertex_state ->
        List.for_all
          (fun (transaction : Transaction.t) ->
            transaction_accepted transaction.identifier)
          vertex_state.vertex.transactions
  in
  transaction_accepted transaction_identifier

let preferred_frontier (dag : Ledger.dag) =
  let strongly_preferred =
    Hashtbl.fold
      (fun _ (vertex_state : Ledger.vertex_state) preferred ->
        if is_strongly_preferred dag vertex_state.vertex then
          vertex_state.vertex :: preferred
        else preferred)
      dag.vertices []
  in
  let referenced = Hashtbl.create 100 in
  List.iter
    (fun (vertex : Vertex.t) ->
      List.iter
        (fun parent -> Hashtbl.replace referenced parent ())
        vertex.parents)
    strongly_preferred;
  List.filter_map
    (fun (vertex : Vertex.t) ->
      if Hashtbl.mem referenced vertex.identifier then None
      else Some vertex.identifier)
    strongly_preferred
  |> List.sort String.compare
