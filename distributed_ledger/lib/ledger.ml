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

(* Update Confidence and Consecutive Success for Ancestors *)
let update_confidence_and_success vertex tx_id threshold =
  let update_fn v =
    List.iter (fun tx ->
      if tx.id = tx_id then (
        tx.confidence <- tx.confidence + 1;
        if tx.confidence >= threshold then (
          tx.consecutive_success <- tx.consecutive_success + 1;
          tx.chit <- true;
          if tx.consecutive_success >= threshold then (
            v.accepted <- Some true
          )
        )
      )
    ) v.transactions
  in
  let visited = Hashtbl.create 100 in
  traverse_dag vertex update_fn visited

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

