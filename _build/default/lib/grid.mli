type transform_queue

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

val make_cell : float -> float -> float -> float -> grid
val uni_with_cell_dim : float -> float -> float -> float -> int -> int -> grid
val uni_sqr_with_cell_dim : float -> float -> float -> int -> grid
val uni_with_size : float -> float -> float -> float -> int -> int -> grid
val uni_sqr_with_size : float -> float -> float -> int -> grid

val iter : (grid -> unit) -> grid -> unit
val int_coords : grid -> int * int * int * int

val center : grid -> float * float
val center_to_corner : float * float * float * float -> float * float
