let () =
  Alcotest.run "distributed_ledger"
    [
      Test_encoding.suite;
      Test_transaction.suite;
      Test_vertex.suite;
      Test_ledger.suite;
      Test_codec.suite;
      Test_storage.suite;
      Test_configuration.suite;
      Test_consensus.suite;
    ]
