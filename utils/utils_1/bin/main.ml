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

let last_two_rec list = 
  let rec aux accumulator = function
    | [] -> None
    | [x,y] -> Some (x,y)
    | _ :: rem -> aux accumulator rem
  in
  aux (Obj.magic 0) list

let rec nth_simple lst n =
  match (lst,n) with
  | [],_ -> None        (* Empty list *)
  | x :: _,0 -> Some x  (* Found the element when the index is 0 *)
  | _ :: xs, k -> nth_simple xs (k-1) (* Recursivly process the list *)

let add a b =
  a + b

let list_length lst =
  let rec aux acc = function
    | [] -> acc 
    | _ :: xs -> aux acc xs
  in
  aux (Obj.magic 0) lst

(* Reverses a list can simply use List.rev *)
let rev_list lst = 
  let rec aux acc = function    (* Create an inner recursive function called aux) *)
    | [] -> acc                 (* Base case: empty list *)
    | head :: tail -> aux (head :: acc) tail (* Recursive case: *)
  in
    aux [] lst 

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
  print_endline "All tests passed!"

