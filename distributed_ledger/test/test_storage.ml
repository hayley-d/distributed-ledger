open Distributed_dag_blockchain

let vertex_option_result =
  Alcotest.result (Alcotest.option Fixtures.vertex) Alcotest.string

let stored_vertex () =
  Vertex.create
    ~parents:[ Vertex.genesis.identifier ]
    ~transactions:[ Fixtures.signed_transaction () ]

let test_round_trip_across_reopen () =
  Fixtures.with_temporary_directory (fun directory ->
      let path = Filename.concat directory "ledger" in
      let vertex = stored_vertex () in
      let database = Storage.open_database ~path in
      Storage.store_vertex database vertex;
      Storage.close_database database;
      let reopened = Storage.open_database ~path in
      Fun.protect
        ~finally:(fun () -> Storage.close_database reopened)
        (fun () ->
          Alcotest.check vertex_option_result "vertex after reopen"
            (Ok (Some vertex))
            (Storage.find_vertex reopened vertex.identifier)))

let test_store_twice () =
  Fixtures.with_temporary_directory (fun directory ->
      let database = Storage.open_database ~path:directory in
      Fun.protect
        ~finally:(fun () -> Storage.close_database database)
        (fun () ->
          let vertex = stored_vertex () in
          Storage.store_vertex database vertex;
          Storage.store_vertex database vertex;
          Alcotest.check vertex_option_result "vertex stored once"
            (Ok (Some vertex))
            (Storage.find_vertex database vertex.identifier)))

let test_unknown_identifier () =
  Fixtures.with_temporary_directory (fun directory ->
      let database = Storage.open_database ~path:directory in
      Fun.protect
        ~finally:(fun () -> Storage.close_database database)
        (fun () ->
          Alcotest.check vertex_option_result "unknown identifier" (Ok None)
            (Storage.find_vertex database "unknown")))

let test_creates_missing_directory () =
  Fixtures.with_temporary_directory (fun directory ->
      let path = Filename.concat directory "missing" in
      let database = Storage.open_database ~path in
      Storage.close_database database;
      Alcotest.(check bool) "directory created" true (Sys.is_directory path))

let suite =
  ( "Storage",
    [
      Alcotest.test_case "round trip across reopen" `Quick
        test_round_trip_across_reopen;
      Alcotest.test_case "store twice" `Quick test_store_twice;
      Alcotest.test_case "unknown identifier" `Quick test_unknown_identifier;
      Alcotest.test_case "creates missing directory" `Quick
        test_creates_missing_directory;
    ] )
