(lang dune 3.23)

(name grid-caml)

(generate_opam_files true)

(source
 (github username/reponame))

(authors "Christopher Sumnicht <csumncht@berkeley.edu>")

(maintainers "Christopher Sumnicht <csumnicht@berkeley.edu>")

(license LICENSE)

(documentation https://url/to/documentation)

(package
 (name grid-caml)
 (synopsis "A small easy grid coordinate helper")
 (description "Grids play a fundamental role in games. Easily create grids with various construction methods. Instead of thinking in realworld coordinates, access grid squares via indices and have the library do the conversion for you.")
 (depends
   (ocaml (>= "5.4.0" )))
 (tags
  ("add topics" "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/reference/dune-project/index.html
