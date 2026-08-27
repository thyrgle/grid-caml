module IntTransformOrder = struct
  type t = int * Obj.t (* Need Obj.t otherwise there is an unresolvable circular dep with [grid] type. *)
  let compare (p1, _) (p2, _) = Stdlib.compare p1 p2
end
module MinPQueue = Pqueue.MakeMin(IntTransformOrder)

type transform_queue = MinPQueue.t

type grid =
{
  x: float;
  y: float;
  w: float;
  h: float;
  children: grid array array;
  transforms: transform_queue;
  children_transforms: transform_queue;
}

let make_cell (x: 'float) (y: 'float) (w: 'float) (h: 'float): grid =
{
  x=x; y=y; 
  w=w; h=h;
  children = [|[||]|];
  transforms=MinPQueue.create ();
  children_transforms=MinPQueue.create ();
}

let ( *$ ) (a: float) (b: int) = a *. Int.to_float b
let ( $* ) (a: int) (b: float) = Int.to_float a *. b

let uni_with_cell_dim
  (x: float) (y: float)
  (cw: float) (ch: float)
  (row_ct: int) (col_ct: int): grid =
  let w = cw *$ col_ct in
  let h = ch *$ row_ct in
  let cell_coord = 
    Array.init_matrix row_ct col_ct 
    (fun x y -> (x $* cw, y $* ch)) in
  let children = Array.init_matrix row_ct col_ct (fun x y ->
    make_cell (fst cell_coord.(x).(y)) (snd cell_coord.(x).(y)) cw ch) in
  {
    x=x; y=y;
    w=w; h=h;
    children=children;
    transforms=MinPQueue.create ();
    children_transforms=MinPQueue.create ();
  }

let uni_sqr_with_cell_dim (x: float) (y: float) (cw :float) (rc_ct: int) =
  uni_with_cell_dim x y cw cw rc_ct rc_ct

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
    transforms=MinPQueue.create ();
    children_transforms=MinPQueue.create ();
  }

let uni_sqr_with_size (x: float) (y: float) (w: float) (row_ct: int) (col_ct: int) = 
  uni_with_size x y w w row_ct col_ct

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

let center (g: grid): float * float = (g.x +. (g.w /. 2.), (g.y +. (g.h /. 2.)))
let center_to_corner (t: float * float * float * float) = 
  let x, y, w, h = t in
  (x -. w /. 2.0, y -. h /. 2.0)
