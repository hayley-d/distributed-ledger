open Distributed_dag_blockchain

let initialise_random_generator = lazy (Mirage_crypto_rng_unix.use_default ())

let generate_private_key ~seed =
  Lazy.force initialise_random_generator;
  let generator =
    Mirage_crypto_rng.create ~seed (module Mirage_crypto_rng.Fortuna)
  in
  Mirage_crypto_pk.Rsa.generate ~g:generator ~bits:2048 ()

let private_key = lazy (generate_private_key ~seed:"fixture private key")

let other_private_key =
  lazy (generate_private_key ~seed:"fixture other private key")

let signed_transaction ?(conflict_key = "coin") ?(data = "pay alice") () =
  Transaction.sign ~private_key:(Lazy.force private_key) ~conflict_key ~data

let unsigned_transaction ?(conflict_key = "coin") ?(data = "pay alice")
    ?(public_key = "public key") ?(signature = "signature") () =
  Transaction.create ~conflict_key ~data ~public_key ~signature

let rec remove_recursively path =
  if Sys.is_directory path then (
    Array.iter
      (fun entry -> remove_recursively (Filename.concat path entry))
      (Sys.readdir path);
    Sys.rmdir path)
  else Sys.remove path

let with_temporary_directory run =
  let directory = Filename.temp_dir "distributed_ledger_test" "" in
  Fun.protect
    ~finally:(fun () -> remove_recursively directory)
    (fun () -> run directory)

let write_file path contents =
  Out_channel.with_open_text path (fun channel ->
      Out_channel.output_string channel contents)

let contains ~fragment text =
  let fragment_length = String.length fragment in
  let rec search offset =
    offset + fragment_length <= String.length text
    && (String.sub text offset fragment_length = fragment || search (offset + 1))
  in
  search 0

let is_error = function Error _ -> true | Ok _ -> false

let vertex =
  Alcotest.testable
    (fun formatter (vertex : Vertex.t) ->
      Format.pp_print_string formatter vertex.identifier)
    ( = )

let property test = QCheck_alcotest.to_alcotest ~speed_level:`Quick test
