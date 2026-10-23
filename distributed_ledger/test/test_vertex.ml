open Distributed_dag_blockchain

let test_genesis_identifier_pinned () =
  Alcotest.(check string)
    "genesis identifier"
    "374708fff7719dd5979ec875d56cd2286f6d3cf7ec317a3b25632aab28ec37bb"
    Vertex.genesis.identifier

let test_create_deterministic () =
  let transactions = [ Fixtures.unsigned_transaction () ] in
  let parents = [ Vertex.genesis.identifier ] in
  Alcotest.(check string)
    "same contents give same identifier"
    (Vertex.create ~parents ~transactions).identifier
    (Vertex.create ~parents ~transactions).identifier

let test_parent_order_matters () =
  let transactions = [ Fixtures.unsigned_transaction () ] in
  Alcotest.(check bool)
    "parent order changes identifier" true
    ((Vertex.create ~parents:[ "first"; "second" ] ~transactions).identifier
   <> (Vertex.create ~parents:[ "second"; "first" ] ~transactions).identifier)

let test_transactions_matter () =
  let parents = [ Vertex.genesis.identifier ] in
  Alcotest.(check bool)
    "different transactions change identifier" true
    ((Vertex.create ~parents
        ~transactions:[ Fixtures.unsigned_transaction ~data:"first" () ])
       .identifier
   <> (Vertex.create ~parents
         ~transactions:[ Fixtures.unsigned_transaction ~data:"second" () ])
        .identifier)

let suite =
  ( "Vertex",
    [
      Alcotest.test_case "genesis identifier pinned" `Quick
        test_genesis_identifier_pinned;
      Alcotest.test_case "create deterministic" `Quick test_create_deterministic;
      Alcotest.test_case "parent order matters" `Quick test_parent_order_matters;
      Alcotest.test_case "transactions matter" `Quick test_transactions_matter;
    ] )
