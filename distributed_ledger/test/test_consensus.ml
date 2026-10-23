open Distributed_dag_blockchain

let test_query_transaction () =
  List.iter
    (fun (description, votes, expected) ->
      Alcotest.(check bool)
        description expected
        (Consensus.query_transaction votes))
    [
      ("majority yes", [ true; true; false ], true);
      ("tie", [ true; false ], false);
      ("no votes", [], false);
      ("majority no", [ false; false; true ], false);
    ]

let suite =
  ( "Consensus",
    [ Alcotest.test_case "query transaction" `Quick test_query_transaction ] )
