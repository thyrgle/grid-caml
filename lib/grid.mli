(** Description *)

(** {1 The Fundamental Type: [grid] *)

(** A type that is used to "represent" a grid. In particular, you can construct a grid and then extract real-
    world coordinates from the grid and use them in an application. *)
type grid

type transformation

val iter : (grid -> unit) -> grid -> unit


(** {1 Grid Constructors} *)

(** Makes a grid that is just a single square conceptually. *)
val make_cell : ?parent:(grid option) -> float -> float -> float -> float -> grid

(** Create a grid and populate it with evenly spaced children. Furthermore, the children have the specified
    width and height. *)
val uni_with_cell_dim : float -> float -> float -> float -> int -> int -> grid

(** Create a square grid populate it with evenly spaced children. Furthermore, the children have the 
    specified width and height. *)
val uni_sqr_with_cell_dim : float -> float -> float -> int -> int -> grid

(** Create a grid with specified dimensions and populate it with evenly spaced children. *)
val uni_with_size : float -> float -> float -> float -> int -> int -> grid

(** Create a square grid with specified dimensions and populate it with evenly spaced children. *)
val uni_sqr_with_size : float -> float -> float -> int -> int -> grid

(** Extract the float coordinates from a specified grid. *)
val coords : grid -> float * float * float * float

(** Extract the int coordinates from a specified grid. *)
val int_coords : grid -> int * int * int * int

(** {1 Grid transformations} *)

(** {2 Tranformation Applicators} *)

(** Apply a specified transformation to the specified grid. *)
val apply_transform : transformation -> grid -> unit

(** Shorthand for [apply_transform]. *)
val  (+>): transformation -> grid -> unit

(** Apply a specified transformation to be applied to the grid's children. *)
val apply_children_transform : transformation -> grid -> unit

(** Shorthand for [apply_children_transform]. *)
val  (++>): transformation -> grid -> unit

(** {2 Common (built-in) Transformations} *)

(** {3 Setters } *)

(** Sets the x coordinate of a grid to a particular value. *)
val set_x : float -> transformation

(** Sets the x coordinate of a grid to a particular value. *)
val set_y : float -> transformation

(** Sets the width of a grid to a particular value. *)
val set_w : float -> transformation

(** Sets the height of a grid to a particular value. *)
val set_h : float -> transformation

(** {3 Translators } *)

(** Translate by some number in the x axis. *)
val tx : float -> transformation

(** Translate by some number in the y axis. *)
val ty : float -> transformation

(** Augment or decrease width by specified amount. *)
val tw : float -> transformation

(** Augment or decreate height by specified amount. *)
val th : float -> transformation

(** {3 Paddings } *)

(** Apply padding to left side of grid. *)
val pl : float -> transformation

(** Apply padding to right side of grid *)
val pr : float -> transformation

(** Apply padding to left and right side of grid. *)
val px : float -> transformation

(** Apply padding to top side of grid. *)
val pt : float -> transformation

(** Apply padding to bottom side of grid. *)
val pb : float -> transformation

(** Apply padding to top and bottom side of grid. *)
val py : float -> transformation

(** Apply padding to all sides of grid. *)
val p : float -> transformation
