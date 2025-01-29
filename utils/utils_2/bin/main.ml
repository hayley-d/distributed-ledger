(* Function that counts how many elements in a list are equal to a given value *)
let count_elem lst x = 
    let rec aux acc = function
    | [] -> acc
    | h :: t -> if h = x then aux (acc + 1) t else aux acc t 
    in
    aux 0 lst


(* A function that applies a function to evey third element *)
let basic_foo x = x * 5

let transform_thrid foo lst = 
    let rec aux acc = function
        | a::b::c:: t -> aux (basic_foo c)::acc
        |_ -> List.rev acc
    in
    aux [] lst

    
let () = Printf.printf "%d\n" (count_elem [1;2;1;3;1] 1)

