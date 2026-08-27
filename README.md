# grid-caml

Grids play a fundamental role in many applications, from games to web layout. In game dev, for example, you often need to move a character from one grid cell to another. This sounds simple, but it's surprisingly tedious in practice: you have to keep track of how a cell's index maps to its coordinates on screen. Conceptually, a character moves from cell `(0, 0)` to cell `(0, 1)` — but in terms of screen coordinates, that might mean moving from `(20, 20)` to `(20, 65)`. Reasoning about raw pixel coordinates like that is far less natural than reasoning about grid indices.

`grid-caml` lets you think in indices instead of real-world coordinates. It makes it easy to define grids for game worlds or UI layouts, and to convert between cell indices and their corresponding on-screen coordinates whenever you need to. Going back to the example above, once you have your grid set up. `Grid.coord g.(0).(1)` will just give you `(20, 65)`.
