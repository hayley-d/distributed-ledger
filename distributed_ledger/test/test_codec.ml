open Distributed_dag_blockchain

let vertex_result = Alcotest.result Fixtures.vertex Alcotest.string

let encode_message message =
  let encoder = Pbrt.Encoder.create () in
  Avalanche_pb.encode_pb_vertex message encoder;
  Pbrt.Encoder.to_string encoder

let signed_vertex () =
  Vertex.create
    ~parents:[ Vertex.genesis.identifier ]
    ~transactions:[ Fixtures.signed_transaction () ]

let test_round_trip_signed_vertex () =
  let vertex = signed_vertex () in
  Alcotest.check vertex_result "signed vertex" (Ok vertex)
    (Codec.decode_vertex (Codec.encode_vertex vertex))

let test_round_trip_genesis () =
  Alcotest.check vertex_result "genesis" (Ok Vertex.genesis)
    (Codec.decode_vertex (Codec.encode_vertex Vertex.genesis))

let test_rejects_tampered_vertex_identifier () =
  let message = Codec.vertex_to_protobuf (signed_vertex ()) in
  Avalanche_pb.vertex_set_identifier message "tampered";
  Alcotest.(check bool)
    "tampered vertex identifier rejected" true
    (Fixtures.is_error (Codec.decode_vertex (encode_message message)))

let test_rejects_tampered_transaction_identifier () =
  let vertex = signed_vertex () in
  let transaction_messages =
    List.map
      (fun transaction ->
        let transaction_message = Codec.transaction_to_protobuf transaction in
        Avalanche_pb.transaction_set_identifier transaction_message "tampered";
        transaction_message)
      vertex.transactions
  in
  let message =
    Avalanche_pb.make_vertex ~identifier:vertex.identifier
      ~parents:vertex.parents ~transactions:transaction_messages ()
  in
  Alcotest.(check bool)
    "tampered transaction identifier rejected" true
    (Fixtures.is_error (Codec.decode_vertex (encode_message message)))

let test_rejects_garbage () =
  Alcotest.(check bool)
    "garbage rejected" true
    (Fixtures.is_error (Codec.decode_vertex "\xff\xff\xff"))

let test_rejects_truncated_nested_field () =
  Alcotest.(check bool)
    "truncated nested field rejected" true
    (Fixtures.is_error
       (Codec.decode_vertex "\130a\128\128\128\128\128\128\128\128aaaaaa"))

let transaction_generator =
  QCheck2.Gen.(
    map2
      (fun (conflict_key, data) (public_key, signature) ->
        Fixtures.unsigned_transaction ~conflict_key ~data ~public_key ~signature
          ())
      (pair string_small string_small)
      (pair string_small string_small))

let vertex_generator =
  QCheck2.Gen.(
    map2
      (fun parents transactions -> Vertex.create ~parents ~transactions)
      (list_small string_small)
      (list_small transaction_generator))

let round_trip_property =
  QCheck2.Test.make ~name:"vertex round trip" ~count:300
    ~print:(fun (vertex : Vertex.t) -> vertex.identifier)
    vertex_generator
    (fun vertex -> Codec.decode_vertex (Codec.encode_vertex vertex) = Ok vertex)

let never_raises_property =
  QCheck2.Test.make ~name:"decoding arbitrary bytes never raises" ~count:1000
    ~print:QCheck2.Print.string QCheck2.Gen.string (fun input ->
      match Codec.decode_vertex input with Ok _ | Error _ -> true)

let suite =
  ( "Codec",
    [
      Alcotest.test_case "round trip signed vertex" `Quick
        test_round_trip_signed_vertex;
      Alcotest.test_case "round trip genesis" `Quick test_round_trip_genesis;
      Alcotest.test_case "rejects tampered vertex identifier" `Quick
        test_rejects_tampered_vertex_identifier;
      Alcotest.test_case "rejects tampered transaction identifier" `Quick
        test_rejects_tampered_transaction_identifier;
      Alcotest.test_case "rejects garbage" `Quick test_rejects_garbage;
      Alcotest.test_case "rejects truncated nested field" `Quick
        test_rejects_truncated_nested_field;
      Fixtures.property round_trip_property;
      Fixtures.property never_raises_property;
    ] )
