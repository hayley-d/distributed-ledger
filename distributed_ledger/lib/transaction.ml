type t = {
  identifier : string;
  conflict_key : string;
  data : string;
  public_key : string;
  signature : string;
}

let compute_identifier ~conflict_key ~data ~public_key =
  Encoding.hex_sha256 [ conflict_key; data; public_key ]

let create ~conflict_key ~data ~public_key ~signature =
  {
    identifier = compute_identifier ~conflict_key ~data ~public_key;
    conflict_key;
    data;
    public_key;
    signature;
  }

let encode_public_key (public_key : Mirage_crypto_pk.Rsa.pub) =
  Encoding.length_prefixed
    [
      Mirage_crypto_pk.Z_extra.to_octets_be public_key.n;
      Mirage_crypto_pk.Z_extra.to_octets_be public_key.e;
    ]

let decode_public_key encoded =
  match Encoding.split_length_prefixed encoded with
  | Ok [ modulus; exponent ] -> (
      match
        Mirage_crypto_pk.Rsa.pub
          ~e:(Mirage_crypto_pk.Z_extra.of_octets_be exponent)
          ~n:(Mirage_crypto_pk.Z_extra.of_octets_be modulus)
      with
      | Ok public_key -> Ok public_key
      | Error (`Msg message) -> Error message)
  | Ok _ -> Error "public key must contain exactly a modulus and an exponent"
  | Error message -> Error message

let sign ~private_key ~conflict_key ~data =
  let public_key =
    encode_public_key (Mirage_crypto_pk.Rsa.pub_of_priv private_key)
  in
  let identifier = compute_identifier ~conflict_key ~data ~public_key in
  let signature =
    Mirage_crypto_pk.Rsa.PKCS1.sign ~hash:`SHA256 ~key:private_key
      (`Message identifier)
  in
  { identifier; conflict_key; data; public_key; signature }

let verify transaction =
  let expected_identifier =
    compute_identifier ~conflict_key:transaction.conflict_key
      ~data:transaction.data ~public_key:transaction.public_key
  in
  transaction.identifier = expected_identifier
  &&
  match decode_public_key transaction.public_key with
  | Error _ -> false
  | Ok key ->
      Mirage_crypto_pk.Rsa.PKCS1.verify
        ~hashp:(fun hash -> hash = `SHA256)
        ~key ~signature:transaction.signature (`Message transaction.identifier)
