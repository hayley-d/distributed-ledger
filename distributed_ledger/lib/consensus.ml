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

let query_transaction quorum =
    let yes_votes = List.fold_left (fun acc vote -> if vote then (acc + 1) else acc) 0 quorum in
    yes_votes > (List.length quorum / 2)
