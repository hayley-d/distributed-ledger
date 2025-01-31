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

(* Get a transaction by ID *)
let get_transaction ledger tx_id =
    StringMap.find_opt tx_id ledger.transactions

(* Get parent transactions *)
let get_parents ledger tx =
    List.filter_map (fun id -> get_transaction ledger id) tx.parents

(* Get child transactions *)
let get_children ledger tx_id =
    match StringMap.find_opt tx_id ledger.references with
    | Some children -> List.filter_map (fun id -> get_transaction ledger id) children
    | None -> []


(* Perform a traversal for validation *)
let validate_transaction ledger tx =
    List.for_all (transaction_exists ledger) tx.parents



