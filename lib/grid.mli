type grid

val make_cell : float -> float -> float -> float -> grid
val uni_with_cell_dim : float -> float -> float -> float -> int -> int -> grid
val uni_sqr_with_cell_dim : float -> float -> float -> int -> int -> grid
val uni_with_size : float -> float -> float -> float -> int -> int -> grid
val uni_sqr_with_size : float -> float -> float -> int -> int -> grid

val iter : (grid -> unit) -> grid -> unit
val int_coords : grid -> int * int * int * int
