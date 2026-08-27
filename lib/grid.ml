type grid =
{
  x: float;
  y: float;
  w: float;
  h: float;
  children: grid array array;
  mutable transforms: (grid -> grid) list;
  mutable children_transforms: (grid -> grid) list;
}

let make_cell (x: 'float) (y: 'float) (w: 'float) (h: 'float): grid =
{
  x=x; y=y; 
  w=w; h=h;
  children = [|[||]|];
  transforms=[];
  children_transforms=[];
}

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
    {
      x=x; y=y;
      w=w; h=h;
      children=children;
      transforms=[];
      children_transforms=[];
    }

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
  {
    x=x; y=y;
    w=w; h=h;
    children=children;
    transforms=[];
    children_transforms=[];
  }

let uni_sqr_with_cell_dim x y cw row_ct col_ct = uni_with_cell_dim x y cw cw row_ct col_ct
let reg_sqr_with_cell_dim x y cw rc_ct = uni_sqr_with_cell_dim x y cw rc_ct rc_ct

let ( /$ ) (a: float) (b: int) = a /. Int.to_float b

let uni_with_size
  (x: float) (y: float)
  (w: float) (h: float)
  (row_ct: int) (col_ct: int): grid =
  let cw = w /$ col_ct in
  let ch = h /$ row_ct in
  let cell_coord =
    Array.init_matrix row_ct col_ct
    (fun x y -> (x $* cw, y $* ch)) in
  let children = Array.init_matrix row_ct col_ct (fun x y ->
    make_cell (fst cell_coord.(x).(y)) (snd cell_coord.(x).(y)) cw ch) in
  {
    x=x; y=y;
    w=w; h=h;
    children=children;
    transforms=[];
    children_transforms=[];
  }

let uni_sqr_with_size x y w row_ct col_ct = uni_with_size x y w w row_ct col_ct
let reg_sqr_with_size x y w rc_ct = uni_sqr_with_size x y w rc_ct rc_ct

let rec iter (f: grid -> unit) (g: grid): unit =
  if (g.children = [|[||]|]) 
  then (f g)
  else (Array.iter (fun row ->
    Array.iter (fun col -> iter f col) row) g.children
  )

let int_coords (g: grid) =
(
  Int.of_float g.x,
  Int.of_float g.y,
  Int.of_float g.w,
  Int.of_float g.h
)

let coords (g: grid) = (g.x, g.y, g.w, g.h)

let apply_transform (transform: grid -> grid) (g: grid) = g.transforms <- transform :: g.transforms
let (+>) = apply_transform

let apply_children_transform (transform: grid -> grid) (g: grid) = 
  g.children_transforms <- transform :: g.children_transforms
let (++>) = apply_children_transform
