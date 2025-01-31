module StringMap = Map.Make(String)

type ledger = {
    transactions : transaction StringMap.t; (* Store transactions by ID *)
    references : (string list) StringMap.t; (* Track child transactions *)
}

(* Initialize an empty ledger *)
let empty_ledger = {
    transactions = StringMap.empty;
    references = StringMap.empty;
}

(* Add a transaction to the DAG *)
let add_transaction ledger tx =
    let transactions = StringMap.add tx.id tx ledger.transactions in
    let references = List.fold_left (fun acc parent_id ->
        let updated_children =
            match StringMap.find_opt parent_id acc with
            | Some chidren -> tx.id :: children
            | None -> [tx.id]
        in
        StringMap.add parent_id updated_children acc
    ) ledger.references tx.parents in 
    { transactions; references}

(* Check if a transaction exists *)
let transaction_exists ledger tx_id =
    StringMap.mem tx_id ledger.transactions
