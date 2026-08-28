type cell =
{
  x: float; ix: float;
  y: float; iy: float;
  w: float; iw: float;
  h: float; ih: float;
}

let zero_cell =
{
  x=0.0; ix=0.0;
  y=0.0; iy=0.0;
  w=0.0; iw=0.0;
  h=0.0; ih=0.0;
}

type transformation = (cell -> cell)

type grid =
{
  mutable cell: cell option;
  mutable children: grid array array;
  mutable parent: grid option;
  mutable transforms: transformation list;
  mutable itransforms: transformation list;
  mutable children_transforms: transformation list;
}

let default_grid =
{
  cell=None;
  children=[|[||]|];
  parent=None;
  transforms=[];
  itransforms=[];
  children_transforms=[];
}

let compose (funs: ('a -> 'a) list): ('a -> 'a) =
  List.fold_left Fun.compose Fun.id funs

let rec iter (f: grid -> unit) (g: grid): unit =
  if (g.children = [|[||]|]) 
  then (f g)
  else (Array.iter (fun row ->
    Array.iter (fun col -> iter f col) row) g.children
  )

let set_x (new_x: float) = (fun c -> { c with x=new_x })
let set_y (new_y: float) = (fun c -> { c with y=new_y })
let set_w (new_w: float) = (fun c -> { c with w=new_w })
let set_h (new_h: float) = (fun c -> { c with h=new_h })

let tx (by: float) = (fun c -> { c with x=c.x +. by })
let ty (by: float) = (fun c -> { c with x=c.y +. by })
let tw (by: float) = (fun c -> { c with x=c.w +. by })
let th (by: float) = (fun c -> { c with x=c.h +. by })

let pl (pad: float) = (fun c -> { c with x=c.x +. pad; h=c.h -. pad })
let pr (pad: float) = (fun c -> { c with x=c.x +. pad; h=c.h -. pad })
let px (pad: float) = Fun.compose (pl pad) (pr pad)
let pt (pad: float) = (fun c -> { c with x=c.x +. pad; h=c.h -. pad })
let pb (pad: float) = (fun c -> { c with x=c.x +. pad; h=c.h -. pad })
let py (pad: float) = Fun.compose (pt pad) (pb pad)
let p (pad: float) = Fun.compose (px pad) (py pad)

let make_cell ?(parent=None) (x: 'float) (y: 'float) (w: 'float) (h: 'float): grid =
  { default_grid with transforms=[set_x x; set_y y; set_w w; set_h h]; parent=parent; }

let ( *$ ) (a: float) (b: int) = a *. Int.to_float b
let ( $* ) (a: int) (b: float) = Int.to_float a *. b

let make_grid x y w h (row_weights: float array) (col_weights: float array): grid =
  let dimx = Array.length row_weights in
  let dimy = Array.length col_weights in
  let cell_coord =
    Array.init_matrix dimx dimy (fun r c ->
      try 
        (x +. (r $* row_weights.(r-1)), y +. (c $* col_weights.(c-1)))
      with
      | Invalid_argument _ -> (0.0, 0.0))
  in
  let children = Array.init_matrix dimx dimy (fun r c ->
    make_cell (fst cell_coord.(r).(c)) (snd cell_coord.(r).(c))
      (w *. row_weights.(r)) (h *. col_weights.(c))) in
  let container_grid =
    { default_grid with children=children; transforms=[set_x x; set_y y; set_w w; set_h h]} in
  iter (fun child -> child.parent <- Some container_grid) container_grid;
  container_grid

let uni_with_cell_dim
  (x: float) (y: float)
  (cw: float) (ch: float)
  (row_ct: int) (col_ct: int): grid =
  let w = cw *$ col_ct in
  let h = ch *$ row_ct in
  let cell_coord = 
    Array.init_matrix row_ct col_ct 
    (fun r c -> (x +. (r $* cw), y +. (c $* ch))) in
  let children = Array.init_matrix row_ct col_ct (fun r c ->
    make_cell (fst cell_coord.(r).(c)) (snd cell_coord.(r).(c)) cw ch) in
  let container_grid = 
    { default_grid with children=children; transforms=[set_x x; set_y y; set_w w; set_h h]} in
  iter (fun child -> child.parent <- Some(container_grid)) container_grid;
  container_grid

let uni_sqr_with_cell_dim x y cw row_ct col_ct = uni_with_cell_dim x y cw cw row_ct col_ct
let reg_sqr_with_cell_dim x y cw rc_ct = uni_sqr_with_cell_dim x y cw rc_ct rc_ct

let ( /$ ) (a: float) (b: int) = a /. Int.to_float b

let uni_with_size x y w h row_ct col_ct: grid =
  let cw = w /$ col_ct in
  let ch = h /$ row_ct in
  let cell_coord =
    Array.init_matrix row_ct col_ct
    (fun x y -> (x $* cw, y $* ch)) in
  let children = Array.init_matrix row_ct col_ct (fun x y ->
    make_cell (fst cell_coord.(x).(y)) (snd cell_coord.(x).(y)) cw ch) in
  let container_grid = 
    { default_grid with children=children; transforms=[set_x x; set_y y; set_w w; set_h h] } in
  iter (fun child -> child.parent <- Some(container_grid)) container_grid;
  container_grid

let uni_sqr_with_size x y w row_ct col_ct = uni_with_size x y w w row_ct col_ct
let reg_sqr_with_size x y w rc_ct = uni_sqr_with_size x y w rc_ct rc_ct

let apply_transform (transform: transformation) (g: grid) = g.transforms <- transform :: g.transforms
let (+>) = apply_transform

let apply_children_transform (transform: cell -> cell) (g: grid) = 
  g.children_transforms <- transform :: g.children_transforms
let (++>) = apply_children_transform

let rec update (g: grid): unit =
  match g.parent with
  | None -> ()
  | Some(p) -> update p;
  let f = compose g.transforms in
  let fcell = f zero_cell in
  g.cell <- Some fcell

let rec compute (g: grid): unit =
  match g.parent with
  | None -> ()
  | Some p -> compute p;
  match g.cell with
  | None -> (
      let f = compose g.transforms in
      let fcell = f zero_cell in
      g.cell <- Some fcell
    )
  | Some _ -> ()
  
let coords (g: grid): (float * float * float * float) option =
  match g.cell with
  | None -> None
  | Some c -> Some (c.x, c.y, c.w, c.h)

let int_coords (g: grid): (int * int * int * int) option =
  match coords g with
  | None -> None
  | Some (x, y, w, h) -> Some (Int.of_float x, Int.of_float y, Int.of_float w, Int.of_float h)
