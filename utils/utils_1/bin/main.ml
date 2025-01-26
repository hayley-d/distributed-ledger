(* First implementation: Using List.rev *)
let last_rev lst =
  match List.rev lst with
  | [] -> None      (* Empty list returns None *)
  | hd :: _ -> Some hd  (* First element of reversed list is the last of original *)

(* Recursive approach *)
let rec last_recursive = function
  | [] -> None      (* Empty list returns None *)
  | [x] -> Some x   (* Single-element list returns that element *)
  | _ :: xs -> last_recursive xs  (* Recursively process the tail of the list *)

(* Optional: Tail-recursive implementation for larger lists *)
let last_tail_recursive lst =
  let rec aux acc = function
    | [] -> None
    | [x] -> Some x
    | _ :: xs -> aux acc xs
  in
  aux (Obj.magic 0) lst  (* Initial accumulator is a dummy value *)

let () =
  assert (last_recursive [1; 2; 3; 4] = Some 4);
  assert (last_recursive ["a"; "b"; "c"] = Some "c");
  assert (last_recursive [] = None);
  assert (last_rev [1; 2; 3; 4] = Some 4);
  assert (last_rev ["a"; "b"; "c"] = Some "c");
  assert (last_rev [] = None);
  assert (last_tail_recursive [1; 2; 3; 4] = Some 4);
  assert (last_tail_recursive ["a"; "b"; "c"] = Some "c");
  assert (last_tail_recursive [] = None);

