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

let create_block index
