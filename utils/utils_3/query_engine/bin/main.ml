(* open Str *)
(* open Yojson.Basic *)

(* Define the command type *)
type command = 
    | Set of string * string 
    | Get of string * string

let parse_query query =
    try
        let space_idx = String.index query ' ' in
        let command = String.sub query 0 space_idx in
        let rest = String.sub query (space_idx + 1) (String.length query - space_idx - 1) in

        let space_idx2 = String.index rest ' ' in
        let collection = String.sub rest 0 space_idx2 in
        let payload = String.sub rest (space_idx2 + 1) (String.length rest - space_idx2 - 1) in
        
        match String.uppercase_ascii command with
            | "SET" -> Some(Set(collection,payload))
            | "GET" -> Some(Get(collection,payload))
            | _ -> None
    with Not_found -> None
    (* match Str.split (Str.regexp "+") query with
        | "SET" :: collection :: rest -> let json_str = String.concat " " rest in Some (Set (collection, json_str))
        | "GET" :: collection :: rest -> let regex_pattern = String.concat " " rest in Some(Get (collection, regex_pattern))
        | _ -> None *)

let print_command = function
        | Set (collection, json) -> Printf.printf "Command: SET\nCollection: %s\nData: %s\n" collection json
        | Get (collection, regex) -> Printf.printf "Command: GET\nCollection: %s\nRegex: %s\n" collection regex

let rec main_loop () =
    print_string "> ";
    let query = read_line () in
    match parse_query query with
    | Some cmd -> print_command cmd; main_loop()
    | None -> Printf.printf "Invalid command"; main_loop ()

let () = main_loop ()



