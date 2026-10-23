open Distributed_dag_blockchain

let child_of parents data =
  Vertex.create ~parents
    ~transactions:[ Fixtures.unsigned_transaction ~data () ]

let ancestor_identifiers dag vertex =
  let visited = ref [] in
  Ledger.traverse_ancestors dag vertex (fun vertex_state ->
      visited := vertex_state.Ledger.vertex.identifier :: !visited);
  List.sort String.compare !visited

let test_create_dag_holds_genesis () =
  let dag = Ledger.create_dag () in
  Alcotest.(check int) "one vertex" 1 (Hashtbl.length dag.vertices);
  Alcotest.(check bool)
    "genesis present" true
    (Option.is_some (Ledger.get_vertex dag Vertex.genesis.identifier))

let test_add_then_get () =
  let dag = Ledger.create_dag () in
  let vertex = child_of [ Vertex.genesis.identifier ] "first" in
  Ledger.add_vertex dag vertex;
  match Ledger.get_vertex dag vertex.identifier with
  | Some vertex_state ->
      Alcotest.check Fixtures.vertex "stored vertex" vertex vertex_state.vertex
  | None -> Alcotest.fail "vertex missing after add"

let test_re_add_keeps_state () =
  let dag = Ledger.create_dag () in
  let vertex = child_of [ Vertex.genesis.identifier ] "first" in
  Ledger.add_vertex dag vertex;
  (match Ledger.get_vertex dag vertex.identifier with
  | Some vertex_state -> vertex_state.chit <- true
  | None -> Alcotest.fail "vertex missing after add");
  Ledger.add_vertex dag vertex;
  Alcotest.(check int) "no duplicate" 2 (Hashtbl.length dag.vertices);
  match Ledger.get_vertex dag vertex.identifier with
  | Some vertex_state ->
      Alcotest.(check bool) "chit preserved" true vertex_state.chit
  | None -> Alcotest.fail "vertex missing after re-add"

let test_traverse_diamond () =
  let dag = Ledger.create_dag () in
  let left = child_of [ Vertex.genesis.identifier ] "left" in
  let right = child_of [ Vertex.genesis.identifier ] "right" in
  let tip = child_of [ left.identifier; right.identifier ] "tip" in
  List.iter (Ledger.add_vertex dag) [ left; right; tip ];
  Alcotest.(check (list string))
    "each ancestor once, excluding the tip"
    (List.sort String.compare
       [ Vertex.genesis.identifier; left.identifier; right.identifier ])
    (ancestor_identifiers dag tip)

let test_traverse_skips_missing_parent () =
  let dag = Ledger.create_dag () in
  let known = child_of [ Vertex.genesis.identifier ] "known" in
  Ledger.add_vertex dag known;
  let orphan = child_of [ "missing"; known.identifier ] "orphan" in
  Alcotest.(check (list string))
    "known ancestors only"
    (List.sort String.compare [ Vertex.genesis.identifier; known.identifier ])
    (ancestor_identifiers dag orphan)

let suite =
  ( "Ledger",
    [
      Alcotest.test_case "create dag holds genesis" `Quick
        test_create_dag_holds_genesis;
      Alcotest.test_case "add then get" `Quick test_add_then_get;
      Alcotest.test_case "re-add keeps state" `Quick test_re_add_keeps_state;
      Alcotest.test_case "traverse diamond" `Quick test_traverse_diamond;
      Alcotest.test_case "traverse skips missing parent" `Quick
        test_traverse_skips_missing_parent;
    ] )
