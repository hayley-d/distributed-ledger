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

(* Deserialize Protobuf to Transaction *)
let deserialize_transaction (data: string) : transaction =
    let proto_tx = Transaction_pb.Transaction.of_string data in
    {
        id = proto_tx.id;
        chit = proto_tx.chit;
        parents = proto_tx.parents;
        accepted = proto_tx.accepted;
    }


(* Store transaction in RocksDB *)
let store_transaction db (tx: transaction) =
    let key = "tx:" ^ tx.id in
    let value = serialize_transaction tx in 
    Rocksdb.put db key value

(* Reteieve Transaction from RocksDB *)
let get_transaction db (tx_id: string) : transaction option =
    match Rocksdb.get db ("tx:" ^ tx_id) with
        | Some value -> Some (deserialize_transaction value)
        | None -> None


