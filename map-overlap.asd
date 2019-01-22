;;;; map-overlap.asd

(asdf:defsystem #:map-overlap
  :description "Utility for mapping over intersections/overlaps in spans."
  :author "Daniel Keogh <keogh.daniel@gmail.com>"
  :license "Specify license here"
  :depends-on (#:groupby)
  :serial t
  :components ((:file "package")
               (:file "map-overlap")))

