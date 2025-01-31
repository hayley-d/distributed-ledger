(* Block Type *)
    type block = {
    index : int;
    previous_hash: string;
    timestamp: float;
    data: string;
    nonce: int;
    hash : string;
}


let compute_hash index prev_hash timestamp data nonce =
    let input = Printf.sprintf "%d%s%f%s%f%d" index prev_hash timestamp data nonce 
    in to_hex (digest_string input)

let create_block index prev_hash data nonce = 
    let timestamp = Unix.gettimeofday () in
    let hash = compute_hash index prev_hash timestamp data nonce in
    {index;prev_hash = prev_hash;timestamp;data;nonce;hash}

let genesis_block = create_block 0 "0" "Genesis Block" 0

let add_block chain data difficulty =
    let last_block = List.hd chain in
    let timestamp = Unix.gettimeofday () in
    let nonce, hash = validate_hash (last_block.index + 1) last_block.hash timestamp data 0 difficulty in
    let new_block = {index = last_block.index + 1;previous_hash = last_block.hash; timestamp; data;nonce;hash} in
    new_block :: chain

(* Verify blockchain integrity *)
let rec is_valid_chain = function
        |[] | [_] -> true
        | a :: b :: tail -> if a.previous_hash = b.hash && is_valid_chain (b :: tail) then true else false


