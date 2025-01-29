(* Function that counts how many elements in a list are equal to a given value *)
let count_elem lst x = 
    let rec aux acc = function
    | [] -> acc
    | h :: t -> if h = x then aux (acc + 1) t else aux acc t 
    in
    aux 0 lst


(* A function that applies a function to evey third element *)
let basic_foo (x:int) : int = x * 5

let transform_third (foo: int -> int) (lst: int list) : int list = 
    let rec aux (acc: int list) = function
        | a::b::c::t -> aux ((foo c)::b::a::acc) t
        | [a;b] -> List.rev (b::a::acc) (* Handle the remaining elements *)
        | [a] -> List.rev (a::acc) (* Handle the remaining elements *)
        | [] -> List.rev acc (* Handle the remaining elements *)

    in
    aux [] lst

    
let () = 
    (* test count_elem *)
    let test1 = count_elem [1;2;1;3;1] 1 in Printf.printf "count_elem test: found %d occurrences of 1\n" test1;;

    (* Test transform_third *)
    let test_list = [1;2;3;4;5;6;7;8;9] in
    let result = transform_third basic_foo test_list in
    Printf.printf "transform_third test: \nOriginal list: ";
    List.iter (Printf.printf "%d ") test_list;
    Printf.printf "\nTransformed list: ";
    List.iter (Printf.printf "%d ") result ;
    Printf.printf "\n"


