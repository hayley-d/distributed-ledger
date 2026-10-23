let () =
  match Distributed_dag_blockchain.Configuration.load ~path:".env" with
  | Error message ->
      prerr_endline message;
      exit 1
  | Ok configuration ->
      let dag = Distributed_dag_blockchain.Ledger.create_dag () in
      Printf.printf
        "Node started: sample_size=%d quorum_size=%d decision_threshold=%d \
         vertices=%d genesis=%s\n"
        configuration.sample_size configuration.quorum_size
        configuration.decision_threshold
        (Hashtbl.length dag.vertices)
        Distributed_dag_blockchain.Vertex.genesis.identifier
