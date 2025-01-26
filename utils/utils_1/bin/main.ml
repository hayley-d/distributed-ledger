(* First implementation: Using List.rev *)
let last_rev lst =
  match List.rev lst with
  | [] -> None      (* Empty list returns None *)
  | hd :: _ -> Some hd  (* First element of reversed list is the last of original *)


let is_palindrome lst =
  let rec aux acc = function
    | [] -> true
    | [_] -> true
    | head :: tail -> if head = List.hd (List.rev tail) then aux acc tail else false
  in
  aux [] lst

let simple_is_palindrome lst =
  lst = List.rev lst


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

(* Finds the run length encoding of the input list *)
let run_length_encoding lst = 
  let rec aux count acc = function
    | [] -> [] (* If an empty list then output an empty list *)
    | [x] -> (count + 1, x) :: acc  (* If a single element -> increment count of element *)
    | a :: (b :: _ as t) -> if a = b then aux (count + 1) acc t  (* If the fist two elements are the same increment the count and continue with the rest of the list *)
                            else aux 0 ((count + 1, a) :: acc) t in (* If the first two elements are NOT the same add the current run to the accumulator and reset the count to 0*)
  List.rev (aux 0 [] lst)

(* Define a custom type to handle both single elements and runs *)
type 'a run = 
    | One of 'a         (* A single elemnt of any type *)
    | Many of (int * 'a) (* A run of repetead elements *)

let advanced_run_length_encoding lst =
  let rec aux count acc = function
    | [] -> [] (* Empty list *)
    | [x] -> if count == 0 then One x :: acc
             else Many (count +1,x) :: acc (* add the run to the accumulator *)
    | a :: (b :: _ as t) -> if a = b then aux (count + 1) acc t 
                            else let current_element = if count = 0 then One a else Many (count + 1,a)
                                in aux 0 (current_element :: axx) t
  in
  List.rev (aux 0 [] lst)
 
let duplicate_elem lst =
  let rec aux acc = function
    | [] -> []
    | [x] -> [x;x] :: acc
    | a :: tail -> aux ([a;a] :: acc) tail
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

