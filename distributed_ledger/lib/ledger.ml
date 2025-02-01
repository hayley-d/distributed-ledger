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

let add_vertex dag vertex =
    Hashtbl.add dag.verticies vertex.id vertex

let get_vertex dag id =
    Hashtbl.find_opt dag.verticies id
