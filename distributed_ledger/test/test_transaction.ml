open Distributed_dag_blockchain

let encoded_public_key private_key =
  Transaction.encode_public_key (Mirage_crypto_pk.Rsa.pub_of_priv private_key)

let test_identifier_deterministic () =
  let first =
    Transaction.compute_identifier ~conflict_key:"coin" ~data:"pay"
      ~public_key:"key"
  in
  let second =
    Transaction.compute_identifier ~conflict_key:"coin" ~data:"pay"
      ~public_key:"key"
  in
  Alcotest.(check string) "same fields give same identifier" first second

let test_identifier_depends_on_every_field () =
  let base =
    Transaction.compute_identifier ~conflict_key:"coin" ~data:"pay"
      ~public_key:"key"
  in
  let variants =
    [
      Transaction.compute_identifier ~conflict_key:"other" ~data:"pay"
        ~public_key:"key";
      Transaction.compute_identifier ~conflict_key:"coin" ~data:"other"
        ~public_key:"key";
      Transaction.compute_identifier ~conflict_key:"coin" ~data:"pay"
        ~public_key:"other";
    ]
  in
  List.iter
    (fun variant ->
      Alcotest.(check bool) "identifier changes" true (variant <> base))
    variants

let test_create_sets_identifier () =
  let transaction = Fixtures.unsigned_transaction () in
  Alcotest.(check string)
    "identifier matches computed"
    (Transaction.compute_identifier ~conflict_key:transaction.conflict_key
       ~data:transaction.data ~public_key:transaction.public_key)
    transaction.identifier

let test_public_key_round_trip () =
  let encoded = encoded_public_key (Lazy.force Fixtures.private_key) in
  match Transaction.decode_public_key encoded with
  | Ok decoded ->
      Alcotest.(check string)
        "re-encoded key matches" encoded
        (Transaction.encode_public_key decoded)
  | Error message -> Alcotest.fail message

let test_public_key_rejects_invalid_input () =
  let even_modulus = String.make 16 '\x02' in
  List.iter
    (fun encoded ->
      Alcotest.(check bool)
        "invalid public key rejected" true
        (Fixtures.is_error (Transaction.decode_public_key encoded)))
    [
      "garbage";
      Encoding.length_prefixed [ "single field" ];
      Encoding.length_prefixed [ even_modulus; "\x01\x00\x01" ];
    ]

let test_sign_then_verify () =
  Alcotest.(check bool)
    "signed transaction verifies" true
    (Transaction.verify (Fixtures.signed_transaction ()))

let test_verify_rejects_tampering () =
  let transaction = Fixtures.signed_transaction () in
  let recomputed_identifier data public_key =
    Transaction.compute_identifier ~conflict_key:transaction.conflict_key ~data
      ~public_key
  in
  let flipped_signature =
    String.mapi
      (fun index character ->
        if index = 0 then Char.chr (Char.code character lxor 1) else character)
      transaction.signature
  in
  let other_public_key =
    encoded_public_key (Lazy.force Fixtures.other_private_key)
  in
  let tampered_transactions =
    [
      ("stale identifier", { transaction with data = "pay mallory" });
      ( "recomputed identifier",
        {
          transaction with
          data = "pay mallory";
          identifier =
            recomputed_identifier "pay mallory" transaction.public_key;
        } );
      ("flipped signature", { transaction with signature = flipped_signature });
      ( "garbage public key",
        {
          transaction with
          public_key = "garbage";
          identifier = recomputed_identifier transaction.data "garbage";
        } );
      ( "other public key",
        {
          transaction with
          public_key = other_public_key;
          identifier = recomputed_identifier transaction.data other_public_key;
        } );
    ]
  in
  List.iter
    (fun (description, tampered) ->
      Alcotest.(check bool) description false (Transaction.verify tampered))
    tampered_transactions

let suite =
  ( "Transaction",
    [
      Alcotest.test_case "identifier deterministic" `Quick
        test_identifier_deterministic;
      Alcotest.test_case "identifier depends on every field" `Quick
        test_identifier_depends_on_every_field;
      Alcotest.test_case "create sets identifier" `Quick
        test_create_sets_identifier;
      Alcotest.test_case "public key round trip" `Quick
        test_public_key_round_trip;
      Alcotest.test_case "public key rejects invalid input" `Quick
        test_public_key_rejects_invalid_input;
      Alcotest.test_case "sign then verify" `Quick test_sign_then_verify;
      Alcotest.test_case "verify rejects tampering" `Quick
        test_verify_rejects_tampering;
    ] )
