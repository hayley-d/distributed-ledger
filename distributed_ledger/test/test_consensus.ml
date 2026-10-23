open Distributed_dag_blockchain

let configuration =
  { Configuration.sample_size = 4; quorum_size = 3; decision_threshold = 2 }

let peers = [ (); (); (); () ]
let quorum_votes = [ true; true; true; false ]
let failing_votes = [ true; true; false; false ]

let query dag votes vertex =
  Lwt_main.run
    (Consensus.run_query_round configuration
       (Random.State.make [| 0 |])
       dag
       (fun _ _ -> Lwt.return votes)
       peers vertex)

let signed_transactions = Hashtbl.create 16

let transaction ~conflict_key ~data =
  match Hashtbl.find_opt signed_transactions (conflict_key, data) with
  | Some transaction -> transaction
  | None ->
      let transaction = Fixtures.signed_transaction ~conflict_key ~data () in
      Hashtbl.replace signed_transactions (conflict_key, data) transaction;
      transaction

let vertex_of ?(parents = [ Vertex.genesis.identifier ]) ?conflict_key data =
  let conflict_key = Option.value ~default:data conflict_key in
  Vertex.create ~parents ~transactions:[ transaction ~conflict_key ~data ]

let added dag vertex =
  match Consensus.add_vertex dag vertex with
  | Ok () -> vertex
  | Error message -> Alcotest.fail message

let only_transaction (vertex : Vertex.t) =
  match vertex.transactions with
  | [ transaction ] -> transaction
  | _ -> Alcotest.fail "expected exactly one transaction"

let accepted dag vertex =
  Consensus.is_accepted configuration dag (only_transaction vertex).identifier

let preferred dag = Consensus.preferred_transaction dag ~conflict_key:"coin"

let test_rejects_invalid_vertices () =
  let dag = Ledger.create_dag () in
  let valid = vertex_of "valid" in
  List.iter
    (fun (description, vertex) ->
      Alcotest.(check bool)
        description true
        (Fixtures.is_error (Consensus.add_vertex dag vertex)))
    [
      ("unknown parent", vertex_of ~parents:[ "missing" ] "orphan");
      ("no parents", vertex_of ~parents:[] "root");
      ( "no transactions",
        Vertex.create ~parents:[ Vertex.genesis.identifier ] ~transactions:[] );
      ( "invalid signature",
        Vertex.create
          ~parents:[ Vertex.genesis.identifier ]
          ~transactions:[ Fixtures.unsigned_transaction () ] );
      ("forged identifier", { valid with identifier = "forged" });
    ];
  Alcotest.(check int) "nothing stored" 1 (Hashtbl.length dag.vertices)

let test_add_is_idempotent () =
  let dag = Ledger.create_dag () in
  let vertex = added dag (vertex_of "first") in
  query dag quorum_votes vertex;
  Alcotest.(check bool)
    "re-add succeeds" false
    (Fixtures.is_error (Consensus.add_vertex dag vertex));
  Alcotest.(check bool)
    "genesis add succeeds" false
    (Fixtures.is_error (Consensus.add_vertex dag Vertex.genesis));
  Alcotest.(check int)
    "confidence kept" 1
    (Consensus.confidence dag (only_transaction vertex).identifier)

let test_first_seen_is_preferred () =
  let dag = Ledger.create_dag () in
  let alice = added dag (vertex_of ~conflict_key:"coin" "pay alice") in
  let _bob = added dag (vertex_of ~conflict_key:"coin" "pay bob") in
  Alcotest.(check (option string))
    "first seen preferred" (Some (only_transaction alice).identifier)
    (preferred dag)

let test_respond () =
  let dag = Ledger.create_dag () in
  let alice = vertex_of ~conflict_key:"coin" "pay alice" in
  let bob = vertex_of ~conflict_key:"coin" "pay bob" in
  let bob_child = vertex_of ~parents:[ bob.identifier ] "after bob" in
  Alcotest.(check bool)
    "unknown parent refused" false
    (Consensus.respond dag (vertex_of ~parents:[ "missing" ] "orphan"));
  Alcotest.(check bool) "first seen accepted" true (Consensus.respond dag alice);
  Alcotest.(check bool) "conflict refused" false (Consensus.respond dag bob);
  Alcotest.(check bool)
    "descendant of conflict refused" false
    (Consensus.respond dag bob_child);
  Alcotest.(check bool)
    "unknown vertex stored" true
    (Option.is_some (Ledger.get_vertex dag bob_child.identifier))

let test_successful_query_switches_preference () =
  let dag = Ledger.create_dag () in
  let _alice = added dag (vertex_of ~conflict_key:"coin" "pay alice") in
  let bob = added dag (vertex_of ~conflict_key:"coin" "pay bob") in
  let bob_child =
    added dag (vertex_of ~parents:[ bob.identifier ] "after bob")
  in
  query dag quorum_votes bob_child;
  Alcotest.(check int)
    "ancestor confidence" 1
    (Consensus.confidence dag (only_transaction bob).identifier);
  Alcotest.(check (option string))
    "preference switched" (Some (only_transaction bob).identifier)
    (preferred dag)

let test_failed_query_leaves_confidence () =
  let dag = Ledger.create_dag () in
  let vertex = added dag (vertex_of "first") in
  query dag failing_votes vertex;
  Alcotest.(check int)
    "no confidence" 0
    (Consensus.confidence dag (only_transaction vertex).identifier);
  Alcotest.(check (list string))
    "no longer pending" []
    (List.map
       (fun (vertex : Vertex.t) -> vertex.identifier)
       (Consensus.pending_queries dag))

let test_vertex_queried_once () =
  let dag = Ledger.create_dag () in
  let vertex = added dag (vertex_of "first") in
  query dag quorum_votes vertex;
  query dag quorum_votes vertex;
  Alcotest.(check int)
    "counted once" 1
    (Consensus.confidence dag (only_transaction vertex).identifier)

let test_sole_member_accepted_by_confidence () =
  let dag = Ledger.create_dag () in
  let vertex = added dag (vertex_of "first") in
  query dag quorum_votes vertex;
  Alcotest.(check bool) "below threshold" false (accepted dag vertex);
  query dag quorum_votes
    (added dag (vertex_of ~parents:[ vertex.identifier ] "second"));
  Alcotest.(check bool) "at threshold" true (accepted dag vertex)

let conflicted_dag () =
  let dag = Ledger.create_dag () in
  let alice = added dag (vertex_of ~conflict_key:"coin" "pay alice") in
  let bob = added dag (vertex_of ~conflict_key:"coin" "pay bob") in
  let first_child = added dag (vertex_of ~parents:[ alice.identifier ] "one") in
  let second_child =
    added dag (vertex_of ~parents:[ first_child.identifier ] "two")
  in
  (dag, alice, bob, first_child, second_child)

let test_conflict_accepted_by_count () =
  let dag, alice, _bob, first_child, second_child = conflicted_dag () in
  query dag quorum_votes first_child;
  Alcotest.(check bool) "count below threshold" false (accepted dag alice);
  query dag quorum_votes second_child;
  Alcotest.(check bool) "count at threshold" true (accepted dag alice)

let test_failure_resets_count () =
  let dag, alice, bob, first_child, second_child = conflicted_dag () in
  query dag quorum_votes first_child;
  query dag failing_votes bob;
  query dag quorum_votes second_child;
  Alcotest.(check bool) "count restarted" false (accepted dag alice)

let test_unaccepted_parent_blocks_acceptance () =
  let dag, alice, bob, first_child, second_child = conflicted_dag () in
  query dag quorum_votes first_child;
  query dag quorum_votes second_child;
  query dag failing_votes bob;
  Alcotest.(check int)
    "child meets its own rule" 2
    (Consensus.confidence dag (only_transaction first_child).identifier);
  Alcotest.(check bool) "parent undecided" false (accepted dag alice);
  Alcotest.(check bool) "child blocked" false (accepted dag first_child)

let test_preferred_frontier () =
  let dag = Ledger.create_dag () in
  Alcotest.(check (list string))
    "genesis only"
    [ Vertex.genesis.identifier ]
    (Consensus.preferred_frontier dag);
  let alice = added dag (vertex_of ~conflict_key:"coin" "pay alice") in
  let _bob = added dag (vertex_of ~conflict_key:"coin" "pay bob") in
  Alcotest.(check (list string))
    "conflict excluded" [ alice.identifier ]
    (Consensus.preferred_frontier dag);
  let child =
    added dag (vertex_of ~parents:[ alice.identifier ] "after alice")
  in
  Alcotest.(check (list string))
    "child replaces parent" [ child.identifier ]
    (Consensus.preferred_frontier dag)

let sample_property =
  QCheck2.Test.make ~count:200
    ~name:"sample is a distinct subset of size min k n"
    QCheck2.Gen.(triple int (int_range 0 12) (int_range 0 20))
    (fun (seed, sample_size, peer_count) ->
      let peers = List.init peer_count Fun.id in
      let sample random = Consensus.sample_peers random sample_size peers in
      let first = sample (Random.State.make [| seed |]) in
      List.length first = min sample_size peer_count
      && List.length (List.sort_uniq Int.compare first) = List.length first
      && List.for_all (fun peer -> List.mem peer peers) first
      && first = sample (Random.State.make [| seed |]))

let simulation_configuration =
  { Configuration.sample_size = 10; quorum_size = 8; decision_threshold = 10 }

let maximum_rounds = 40

let seeded_payment =
  lazy (Fixtures.signed_transaction ~conflict_key:"seeded" ~data:"pay carol" ())

let alice_payment =
  lazy (Fixtures.signed_transaction ~conflict_key:"coin" ~data:"pay alice" ())

let bob_payment =
  lazy (Fixtures.signed_transaction ~conflict_key:"coin" ~data:"pay bob" ())

let accepted_by node transaction =
  Simulation.accepted_by node simulation_configuration transaction

let honest_acceptance_property =
  QCheck2.Test.make ~count:100 ~name:"honest network accepts a transaction"
    QCheck2.Gen.int (fun seed ->
      let network =
        Simulation.create ~configuration:simulation_configuration ~node_count:20
          ~adversarial_count:0 ~seed
      in
      let payment = Lazy.force seeded_payment in
      Simulation.issue (List.hd network.nodes) payment;
      Simulation.run_until network ~maximum_rounds (fun network ->
          List.for_all (fun node -> accepted_by node payment) network.nodes))

let conflict_settles network =
  let alice = Lazy.force alice_payment in
  let bob = Lazy.force bob_payment in
  let decisions =
    List.map
      (fun node -> (accepted_by node alice, accepted_by node bob))
      (Simulation.honest_nodes network)
  in
  List.for_all (fun decision -> decision = (true, false)) decisions
  || List.for_all (fun decision -> decision = (false, true)) decisions

let never_accepts_both network =
  List.for_all
    (fun node ->
      not
        (accepted_by node (Lazy.force alice_payment)
        && accepted_by node (Lazy.force bob_payment)))
    network.Simulation.nodes

let conflict_property ~name ~adversarial_count =
  QCheck2.Test.make ~count:100 ~name QCheck2.Gen.int (fun seed ->
      let network =
        Simulation.create ~configuration:simulation_configuration ~node_count:20
          ~adversarial_count ~seed
      in
      let honest = Simulation.honest_nodes network in
      Simulation.issue (List.nth honest 0) (Lazy.force alice_payment);
      Simulation.issue (List.nth honest 1) (Lazy.force bob_payment);
      let settled =
        Simulation.run_until network ~maximum_rounds conflict_settles
      in
      settled && never_accepts_both network)

let suite =
  ( "Consensus",
    [
      Alcotest.test_case "rejects invalid vertices" `Quick
        test_rejects_invalid_vertices;
      Alcotest.test_case "add is idempotent" `Quick test_add_is_idempotent;
      Alcotest.test_case "first seen is preferred" `Quick
        test_first_seen_is_preferred;
      Alcotest.test_case "respond" `Quick test_respond;
      Alcotest.test_case "successful query switches preference" `Quick
        test_successful_query_switches_preference;
      Alcotest.test_case "failed query leaves confidence" `Quick
        test_failed_query_leaves_confidence;
      Alcotest.test_case "vertex queried once" `Quick test_vertex_queried_once;
      Alcotest.test_case "sole member accepted by confidence" `Quick
        test_sole_member_accepted_by_confidence;
      Alcotest.test_case "conflict accepted by count" `Quick
        test_conflict_accepted_by_count;
      Alcotest.test_case "failure resets count" `Quick test_failure_resets_count;
      Alcotest.test_case "unaccepted parent blocks acceptance" `Quick
        test_unaccepted_parent_blocks_acceptance;
      Alcotest.test_case "preferred frontier" `Quick test_preferred_frontier;
      Fixtures.property sample_property;
      Fixtures.property honest_acceptance_property;
      Fixtures.property
        (conflict_property ~name:"conflicting transactions settle on one"
           ~adversarial_count:0);
      Fixtures.property
        (conflict_property ~name:"conflict settles despite inverting minority"
           ~adversarial_count:4);
    ] )
