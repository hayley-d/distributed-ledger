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
