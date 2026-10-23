let query_transaction quorum =
  let yes_votes =
    List.fold_left
      (fun count vote -> if vote then count + 1 else count)
      0 quorum
  in
  yes_votes > List.length quorum / 2
