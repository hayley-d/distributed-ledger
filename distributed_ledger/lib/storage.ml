open Rocksdb
open Transaction_pb

let db = Rocksdb.open_db "transactions.db"

(* Serialoze Transaction to Protobuf *)
let serialize_transaction (tx: transaction) : string =
    let proto_tx = Transaction_pb.Transaction.{
        id = tx.id;
        chit = tx.chit;
        parents = List.map (fun p -> p.id) tx.parents;
        accepted = (match tx.accepted with Some true -> true | _ -> false);
    } in
Transaction_pb.Transaction.to_string proto_tx

let store_transaction db tx =
    let key = "tx:" ^ tx.id in
    let value = Printf.sprintf "%b
