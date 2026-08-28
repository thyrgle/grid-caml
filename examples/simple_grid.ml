let setup () =
  Raylib.init_window 800 450 "raylib [core] example - basic window";
  Raylib.set_target_fps 60

let grid = Grid.uni_with_cell_dim 0.0 0.0 50.0 50.0 10 10
let () = Grid.compute grid

let draw_cell (g: Grid.grid) =
  let coords = Grid.int_coords g in
  let x, y, w, h = match coords with
  | None -> (0, 0, 0, 0)
  | Some coord -> coord in
  Raylib.draw_rectangle_lines x y w h Raylib.Color.black

let loop () =
  let open Raylib in
  while not (window_should_close ()) do
    begin_drawing ();
    clear_background Color.raywhite;
    Grid.iter draw_cell grid;
    end_drawing ()
  done;
  close_window ()

let () = setup () |> loop
