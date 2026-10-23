type database = {
  environment : Lmdb.Env.t;
  vertices : (string, string, [ `Uni ]) Lmdb.Map.t;
}

let map_size = 1024 * 1024 * 1024

let open_database ~path =
  if not (Sys.file_exists path) then Sys.mkdir path 0o755;
  let environment = Lmdb.Env.create Lmdb.Rw ~map_size path in
  let vertices =
    Lmdb.Map.create Lmdb.Map.Nodup ~key:Lmdb.Conv.string ~value:Lmdb.Conv.string
      environment
  in
  { environment; vertices }

let close_database database = Lmdb.Env.close database.environment

let store_vertex database (vertex : Vertex.t) =
  try
    Lmdb.Map.add database.vertices vertex.identifier
      (Codec.encode_vertex vertex)
  with Lmdb.Exists -> ()

let find_vertex database identifier =
  match Lmdb.Map.get database.vertices identifier with
  | encoded -> Result.map Option.some (Codec.decode_vertex encoded)
  | exception Lmdb.Not_found -> Ok None
