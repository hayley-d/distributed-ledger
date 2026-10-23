open Distributed_dag_blockchain

let fields_result = Alcotest.(result (list string) string)

let test_empty_fields () =
  Alcotest.(check string) "empty encoding" "" (Encoding.length_prefixed []);
  Alcotest.check fields_result "empty split" (Ok [])
    (Encoding.split_length_prefixed "")

let test_round_trip_special_fields () =
  let fields = [ ""; "\000"; "plain"; "" ] in
  Alcotest.check fields_result "round trip" (Ok fields)
    (Encoding.split_length_prefixed (Encoding.length_prefixed fields))

let test_truncated_prefix () =
  Alcotest.(check bool)
    "truncated prefix rejected" true
    (Fixtures.is_error (Encoding.split_length_prefixed "\000\000\000"))

let test_length_beyond_input () =
  let encoded = Encoding.length_prefixed [ "abcdef" ] in
  let truncated = String.sub encoded 0 (String.length encoded - 1) in
  Alcotest.(check bool)
    "declared length beyond input rejected" true
    (Fixtures.is_error (Encoding.split_length_prefixed truncated))

let test_negative_length () =
  Alcotest.(check bool)
    "negative length rejected" true
    (Fixtures.is_error
       (Encoding.split_length_prefixed (String.make 8 '\xff' ^ "data")))

let test_hex_digest_shape () =
  let digest = Encoding.hex_sha256 [ "field" ] in
  Alcotest.(check int) "digest length" 64 (String.length digest);
  Alcotest.(check bool)
    "lowercase hexadecimal" true
    (String.for_all
       (function '0' .. '9' | 'a' .. 'f' -> true | _ -> false)
       digest)

let test_field_boundaries_matter () =
  Alcotest.(check bool)
    "boundaries change the digest" true
    (Encoding.hex_sha256 [ "ab"; "c" ] <> Encoding.hex_sha256 [ "a"; "bc" ])

let round_trip_property =
  QCheck2.Test.make ~name:"length prefixed round trip" ~count:500
    ~print:QCheck2.Print.(list string)
    QCheck2.Gen.(list_small string_small)
    (fun fields ->
      Encoding.split_length_prefixed (Encoding.length_prefixed fields)
      = Ok fields)

let never_raises_property =
  QCheck2.Test.make ~name:"splitting arbitrary input never raises" ~count:1000
    ~print:QCheck2.Print.string QCheck2.Gen.string (fun input ->
      match Encoding.split_length_prefixed input with Ok _ | Error _ -> true)

let suite =
  ( "Encoding",
    [
      Alcotest.test_case "empty fields" `Quick test_empty_fields;
      Alcotest.test_case "special fields round trip" `Quick
        test_round_trip_special_fields;
      Alcotest.test_case "truncated prefix" `Quick test_truncated_prefix;
      Alcotest.test_case "length beyond input" `Quick test_length_beyond_input;
      Alcotest.test_case "negative length" `Quick test_negative_length;
      Alcotest.test_case "hex digest shape" `Quick test_hex_digest_shape;
      Alcotest.test_case "field boundaries matter" `Quick
        test_field_boundaries_matter;
      Fixtures.property round_trip_property;
      Fixtures.property never_raises_property;
    ] )
