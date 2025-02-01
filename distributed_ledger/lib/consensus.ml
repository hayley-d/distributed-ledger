(* Load configuration from .env *)
let load_config () =
    try
        let ic = open_in ".env" in
        let rec read_lines acc =
            try
                let line = input_line ic in
                let parts = String.split_on_char '=' line in
                match parts with
                | [key;value] -> read_lines ((String.trim key, int_of_string (String trim value)) :: acc)
                | _ -> read_lines acc
            with End_of_file -> close_in ic; acc
        in
        read_lines []
    with _ -> []


(* Transaciton type for consensus determination *)
type transaction = {
    id : string;
    data : string;
    parents : transaction list;
    mutable chit: bool;
    mutable confidence : int;
    mutable consecutive_success : int;
}

(* Initialize a Snowball instance *)
let create (transaction : transaction) (initial_preference: bool) = {
    transaction;
    chit = initial_preference;
    confidence = 0;
    consecutive_success = 0;
}

let query_transaction quorum =
    let yes_votes = List.fold_left (fun acc vote -> if vote then (acc + 1) else acc) 0 quorum in
    yes_votes > (List.length quorum / 2)

let rec update_ancestors transaction =
    transaction.confidence
