type transaction = {
    id : string;
    data: string;
    signature: string;
    mutable chit: bool;
    mutable confidence: float;
    mutable consecutive_success: int;
}

type vertex = {
    id: string;
    transaction: transaction;
    parents: vertex list;
    mutable accepted: bool;
}


type dag = {
    mutable verticies : (string, vertex) Hashtbl.t 
}

let create_dag () = {
    verticies = Hashtbl.create 100 
}

let add_vertex dag vertex =
    Hashtbl.add dag.verticies vertex.id vertex

let get_vertex dag id =
    Hashtbl.find_opt dag.verticies id

let rec traverse_dag vertex f visited =
    if not (Hashtbl.mem visited vertex.id) then (
        Hashtbl.add visited vertex.id true;
    f vertex;
    List.iter (fun parent -> traverse_dag parent f visited) vertex.parents)

let update_ancestors
