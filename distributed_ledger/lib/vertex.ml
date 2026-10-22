type t = {
  identifier : string;
  parents : string list;
  transactions : Transaction.t list;
}

let compute_identifier ~parents ~transactions =
  let transaction_identifiers =
    List.map
      (fun (transaction : Transaction.t) -> transaction.identifier)
      transactions
  in
  Encoding.hex_sha256
    [
      Encoding.length_prefixed parents;
      Encoding.length_prefixed transaction_identifiers;
    ]

let create ~parents ~transactions =
  {
    identifier = compute_identifier ~parents ~transactions;
    parents;
    transactions;
  }

let genesis = create ~parents:[] ~transactions:[]
