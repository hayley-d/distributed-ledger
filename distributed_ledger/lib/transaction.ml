type transaction = {
    id : string; (* Unique transaction ID *)
    parents : string list; (* References to parent transactions *)
    data : string; (* transaction data *)
    signature : string; (* Digital signature for authenticity *)
}

let create_transaction ~id ~parents ~data ~signature =
    {id;parents;data;signature}
