open Distributed_dag_blockchain

let configuration =
  Alcotest.testable
    (fun formatter (configuration : Configuration.t) ->
      Format.fprintf formatter
        "{ sample_size = %d; quorum_size = %d; decision_threshold = %d }"
        configuration.sample_size configuration.quorum_size
        configuration.decision_threshold)
    ( = )

let load_contents contents =
  Fixtures.with_temporary_directory (fun directory ->
      let path = Filename.concat directory ".env" in
      Fixtures.write_file path contents;
      Configuration.load ~path)

let check_error_mentions ~fragment result =
  match result with
  | Ok _ -> Alcotest.failf "expected an error mentioning %s" fragment
  | Error message ->
      Alcotest.(check bool)
        (Printf.sprintf "error %S mentions %s" message fragment)
        true
        (Fixtures.contains ~fragment message)

let test_valid_file () =
  Alcotest.check
    (Alcotest.result configuration Alcotest.string)
    "parsed configuration"
    (Ok
       {
         Configuration.sample_size = 20;
         quorum_size = 15;
         decision_threshold = 15;
       })
    (load_contents
       "# consensus parameters\n\
        SAMPLE_SIZE=20\n\n\
        QUORUM_SIZE = 15\n\
        UNUSED_KEY=anything\n\
        DECISION_THRESHOLD=15\n")

let test_missing_file () =
  Fixtures.with_temporary_directory (fun directory ->
      let path = Filename.concat directory "absent.env" in
      check_error_mentions ~fragment:path (Configuration.load ~path))

let test_missing_key () =
  check_error_mentions ~fragment:"DECISION_THRESHOLD"
    (load_contents "SAMPLE_SIZE=20\nQUORUM_SIZE=15\n")

let test_non_integer_value () =
  check_error_mentions ~fragment:"QUORUM_SIZE"
    (load_contents "SAMPLE_SIZE=20\nQUORUM_SIZE=many\nDECISION_THRESHOLD=15\n")

let test_value_with_separator () =
  check_error_mentions ~fragment:"SAMPLE_SIZE"
    (load_contents "SAMPLE_SIZE=1=2\nQUORUM_SIZE=1\nDECISION_THRESHOLD=1\n")

let test_quorum_exceeds_sample () =
  check_error_mentions ~fragment:"QUORUM_SIZE"
    (load_contents "SAMPLE_SIZE=10\nQUORUM_SIZE=15\nDECISION_THRESHOLD=15\n")

let test_zero_quorum () =
  check_error_mentions ~fragment:"QUORUM_SIZE"
    (load_contents "SAMPLE_SIZE=10\nQUORUM_SIZE=0\nDECISION_THRESHOLD=15\n")

let test_zero_decision_threshold () =
  check_error_mentions ~fragment:"DECISION_THRESHOLD"
    (load_contents "SAMPLE_SIZE=10\nQUORUM_SIZE=5\nDECISION_THRESHOLD=0\n")

let suite =
  ( "Configuration",
    [
      Alcotest.test_case "valid file" `Quick test_valid_file;
      Alcotest.test_case "missing file" `Quick test_missing_file;
      Alcotest.test_case "missing key" `Quick test_missing_key;
      Alcotest.test_case "non-integer value" `Quick test_non_integer_value;
      Alcotest.test_case "value with separator" `Quick test_value_with_separator;
      Alcotest.test_case "quorum exceeds sample" `Quick
        test_quorum_exceeds_sample;
      Alcotest.test_case "zero quorum" `Quick test_zero_quorum;
      Alcotest.test_case "zero decision threshold" `Quick
        test_zero_decision_threshold;
    ] )
