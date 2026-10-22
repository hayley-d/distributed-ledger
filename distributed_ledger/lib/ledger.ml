type vertex_state = { vertex : Vertex.t; mutable chit : bool }

type conflict_set = {
  mutable members : string list;
  mutable preferred : string;
  mutable last : string;
  mutable count : int;
}

type dag = {
  vertices : (string, vertex_state) Hashtbl.t;
  conflict_sets : (string, conflict_set) Hashtbl.t;
  accepted : (string, bool) Hashtbl.t;
}

let add_vertex dag (vertex : Vertex.t) =
  if not (Hashtbl.mem dag.vertices vertex.identifier) then
    Hashtbl.replace dag.vertices vertex.identifier { vertex; chit = false }

let create_dag () =
  let dag =
    {
      vertices = Hashtbl.create 100;
      conflict_sets = Hashtbl.create 100;
      accepted = Hashtbl.create 100;
    }
  in
  add_vertex dag Vertex.genesis;
  dag

let get_vertex dag identifier = Hashtbl.find_opt dag.vertices identifier

let traverse_ancestors dag (vertex : Vertex.t) visit =
  let visited = Hashtbl.create 100 in
  let pending = Queue.of_seq (List.to_seq vertex.parents) in
  while not (Queue.is_empty pending) do
    let identifier = Queue.pop pending in
    if not (Hashtbl.mem visited identifier) then (
      Hashtbl.add visited identifier ();
      match get_vertex dag identifier with
      | Some vertex_state ->
          visit vertex_state;
          List.iter
            (fun parent -> Queue.push parent pending)
            vertex_state.vertex.parents
      | None -> ())
  done

let verify_signature (pub_key: Rsa.pub) (payload: string) (signature: string) : bool =
    let hashed_paylaod = hash (Cstruct.of_string payload) in
let signature_cstruct = Cstruct.of_string signature in
Rsa.PKCS1.verify ~hash:"SHA256" pub_key ~signature:signature_cstruct hashed_payload

(* Example Usage *)
let () =
  let tx1 = { id = "tx1"; valid = true; conflict_set = Some "set1"; confidence = 0; consecutive_success = 0; chit = false } in
  let tx2 = { id = "tx2"; valid = true; conflict_set = Some "set1"; confidence = 0; consecutive_success = 0; chit = false } in
  let v1 = { id = "v1"; transactions = [tx1]; parents = []; accepted = None } in
  let v2 = { id = "v2"; transactions = [tx2]; parents = [v1]; accepted = None } in

  let dag = create_dag () in
  add_vertex dag v1;
  add_vertex dag v2;

  update_confidence_and_success v2 "tx1" 2;

  Printf.printf "Transaction tx1 confidence: %d, consecutive_success: %d, chit: %b\n" tx1.confidence tx1.consecutive_success tx1.chit;
  Printf.printf "Transaction tx2 confidence: %d, consecutive_success: %d, chit: %b\n" tx2.confidence tx2.consecutive_success tx2.chit

