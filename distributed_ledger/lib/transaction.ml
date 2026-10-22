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
