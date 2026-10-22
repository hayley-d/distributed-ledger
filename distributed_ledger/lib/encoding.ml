let length_prefix_size = 8

let length_prefixed fields =
  let buffer = Buffer.create 256 in
  List.iter
    (fun field ->
      Buffer.add_int64_be buffer (Int64.of_int (String.length field));
      Buffer.add_string buffer field)
    fields;
  Buffer.contents buffer

let split_length_prefixed encoded =
  let total_length = String.length encoded in
  let rec read offset fields =
    if offset = total_length then Ok (List.rev fields)
    else if total_length - offset < length_prefix_size then
      Error "truncated length prefix"
    else
      let field_length = String.get_int64_be encoded offset in
      let field_offset = offset + length_prefix_size in
      let remaining_length = Int64.of_int (total_length - field_offset) in
      if
        Int64.compare field_length 0L < 0
        || Int64.compare field_length remaining_length > 0
      then Error "field length exceeds remaining input"
      else
        let field_length = Int64.to_int field_length in
        read
          (field_offset + field_length)
          (String.sub encoded field_offset field_length :: fields)
  in
  read 0 []

let hex_sha256 fields =
  Digestif.SHA256.to_hex
    (Digestif.SHA256.digest_string (length_prefixed fields))
