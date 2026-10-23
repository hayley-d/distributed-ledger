let transaction_to_protobuf (transaction : Transaction.t) =
  Avalanche_pb.make_transaction ~identifier:transaction.identifier
    ~conflict_key:transaction.conflict_key
    ~data:(Bytes.of_string transaction.data)
    ~public_key:(Bytes.of_string transaction.public_key)
    ~signature:(Bytes.of_string transaction.signature)
    ()

let vertex_to_protobuf (vertex : Vertex.t) =
  Avalanche_pb.make_vertex ~identifier:vertex.identifier ~parents:vertex.parents
    ~transactions:(List.map transaction_to_protobuf vertex.transactions)
    ()

let transaction_of_protobuf (message : Avalanche_pb.transaction) =
  let transaction =
    Transaction.create ~conflict_key:message.conflict_key
      ~data:(Bytes.to_string message.data)
      ~public_key:(Bytes.to_string message.public_key)
      ~signature:(Bytes.to_string message.signature)
  in
  if transaction.identifier = message.identifier then Ok transaction
  else
    Error
      (Printf.sprintf "transaction identifier mismatch: %s" message.identifier)

let vertex_of_protobuf (message : Avalanche_pb.vertex) =
  let rec convert_transactions converted = function
    | [] -> Ok (List.rev converted)
    | transaction_message :: remaining -> (
        match transaction_of_protobuf transaction_message with
        | Ok transaction ->
            convert_transactions (transaction :: converted) remaining
        | Error message -> Error message)
  in
  match convert_transactions [] message.transactions with
  | Error message -> Error message
  | Ok transactions ->
      let vertex = Vertex.create ~parents:message.parents ~transactions in
      if vertex.identifier = message.identifier then Ok vertex
      else
        Error
          (Printf.sprintf "vertex identifier mismatch: %s" message.identifier)

let encode_vertex vertex =
  let encoder = Pbrt.Encoder.create () in
  Avalanche_pb.encode_pb_vertex (vertex_to_protobuf vertex) encoder;
  Pbrt.Encoder.to_string encoder

let decode_vertex encoded =
  match Avalanche_pb.decode_pb_vertex (Pbrt.Decoder.of_string encoded) with
  | message -> vertex_of_protobuf message
  | exception Pbrt.Decoder.Failure error ->
      Error (Pbrt.Decoder.error_to_string error)
  | exception Invalid_argument message ->
      Error (Printf.sprintf "malformed vertex encoding: %s" message)
