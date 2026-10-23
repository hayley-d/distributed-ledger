type t = { sample_size : int; quorum_size : int; decision_threshold : int }

let parse_line line =
  let trimmed_line = String.trim line in
  if trimmed_line = "" || trimmed_line.[0] = '#' then None
  else
    match String.index_opt trimmed_line '=' with
    | None -> None
    | Some separator_index ->
        let key = String.trim (String.sub trimmed_line 0 separator_index) in
        let value =
          String.trim
            (String.sub trimmed_line (separator_index + 1)
               (String.length trimmed_line - separator_index - 1))
        in
        Some (key, value)

let read_entries path =
  try
    Ok
      (In_channel.with_open_text path In_channel.input_lines
      |> List.filter_map parse_line)
  with Sys_error message -> Error message

let find_integer entries key =
  match List.assoc_opt key entries with
  | None -> Error (Printf.sprintf "missing configuration key %s" key)
  | Some value -> (
      match int_of_string_opt value with
      | Some integer -> Ok integer
      | None ->
          Error
            (Printf.sprintf "configuration key %s is not an integer: %s" key
               value))

let validate configuration =
  if configuration.quorum_size < 1 then Error "QUORUM_SIZE must be at least 1"
  else if configuration.quorum_size > configuration.sample_size then
    Error "QUORUM_SIZE must not exceed SAMPLE_SIZE"
  else if configuration.decision_threshold < 1 then
    Error "DECISION_THRESHOLD must be at least 1"
  else Ok configuration

let load ~path =
  let ( let* ) = Result.bind in
  let* entries = read_entries path in
  let* sample_size = find_integer entries "SAMPLE_SIZE" in
  let* quorum_size = find_integer entries "QUORUM_SIZE" in
  let* decision_threshold = find_integer entries "DECISION_THRESHOLD" in
  validate { sample_size; quorum_size; decision_threshold }
