open Distributed_dag_blockchain

type node = {
  index : int;
  dag : Ledger.dag;
  random : Random.State.t;
  adversarial : bool;
}

type network = { configuration : Configuration.t; nodes : node list }

let create ~configuration ~node_count ~adversarial_count ~seed =
  {
    configuration;
    nodes =
      List.init node_count (fun index ->
          {
            index;
            dag = Ledger.create_dag ();
            random = Random.State.make [| seed; index |];
            adversarial = index >= node_count - adversarial_count;
          });
  }

let honest_nodes network =
  List.filter (fun node -> not node.adversarial) network.nodes

let filler_transactions =
  lazy
    (Array.init 64 (fun index ->
         Fixtures.signed_transaction
           ~conflict_key:(Printf.sprintf "filler-%d" index)
           ~data:(Printf.sprintf "filler payment %d" index)
           ()))

let filler_transaction round =
  let transactions = Lazy.force filler_transactions in
  if round >= Array.length transactions then
    invalid_arg "simulation ran out of filler transactions"
  else transactions.(round)

let rec deliver ~source ~target identifier =
  if Option.is_none (Ledger.get_vertex target.dag identifier) then
    match Ledger.get_vertex source.dag identifier with
    | None -> ()
    | Some vertex_state ->
        List.iter (deliver ~source ~target) vertex_state.vertex.parents;
        ignore (Consensus.add_vertex target.dag vertex_state.vertex)

let answer ~source target (vertex : Vertex.t) =
  List.iter (deliver ~source ~target) vertex.parents;
  let honest_answer = Consensus.respond target.dag vertex in
  if target.adversarial then not honest_answer else honest_answer

let query_peers source : node Consensus.query_peers =
 fun vertex peers ->
  Lwt.return (List.map (fun target -> answer ~source target vertex) peers)

let issue node transaction =
  let vertex =
    Vertex.create
      ~parents:(Consensus.preferred_frontier node.dag)
      ~transactions:[ transaction ]
  in
  match Consensus.add_vertex node.dag vertex with
  | Ok () -> ()
  | Error message -> failwith ("simulation issued an invalid vertex: " ^ message)

let query_pending network node =
  let peers =
    List.filter (fun peer -> peer.index <> node.index) network.nodes
  in
  Lwt_list.iter_s
    (Consensus.run_query_round network.configuration node.random node.dag
       (query_peers node) peers)
    (Consensus.pending_queries node.dag)

let run_round network round =
  let honest = honest_nodes network in
  issue
    (List.nth honest (round mod List.length honest))
    (filler_transaction round);
  Lwt_main.run (Lwt_list.iter_s (query_pending network) honest)

let run_until network ~maximum_rounds finished =
  let rec loop round =
    if finished network then true
    else if round >= maximum_rounds then false
    else (
      run_round network round;
      loop (round + 1))
  in
  loop 0

let accepted_by node configuration (transaction : Transaction.t) =
  Consensus.is_accepted configuration node.dag transaction.identifier
