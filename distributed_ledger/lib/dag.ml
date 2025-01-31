(* Tip selection selects the latest unreferenced tip in the DAG *)
let monte_carlo_tip_selection dag ~max_walk_length =
    let rec random_walk current_vertex walk_length =
    if walk_length >= max_walk_length then current_vertex else
        let children = get_children dag current_vertex in
            match children with
            | [] -> current_vertex
            | _ -> let weighted_children =
                    children
                    |> List.map (fun child -> (child, calculate_confidence child dag))
                    |> normalize_weights
                    in
                    let next_vertex = weighted_random_select weighted_children in
                    random_walk next_vertex (walk_length + 1)
    in
    let tips = List.init 2 (fun _ -> random_walk (get_genesis_vertex dag) 0) 
    in
    tips

