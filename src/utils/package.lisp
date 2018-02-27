(in-package #:cl-user)


(defpackage :cl-data-structures.utils
  (:use #:common-lisp #:iterate #:alexandria #:serapeum)
  (:nicknames #:cl-ds.utils)
  (:shadowing-import-from #:iterate #:collecting #:summing #:in)
  (:export
   #:bind-lambda
   #:cartesian
   #:cases
   #:cond+
   #:cond-compare
   #:copy-without
   #:distance
   #:distance-matrix
   #:each-in-matrix
   #:erase-from-vector
   #:extendable-vector
   #:fill-distance-matrix-from-vector
   #:import-all-package-symbols
   #:insert-or-replace
   #:lazy-let
   #:lazy-shuffle
   #:let-generator
   #:lexicographic-compare
   #:lower-bound
   #:make-distance-matrix
   #:make-distance-matrix-from-vector
   #:merge-ordered-vectors
   #:mutate-matrix
   #:on-ordered-intersection
   #:optimize-value
   #:ordered-p
   #:parallel-fill-distance-matrix-from-vector
   #:parallel-make-distance-matrix-from-vector
   #:pop-last
   #:read-size
   #:swap-if
   #:swapop
   #:todo
   #:try-find
   #:try-find-cell
   #:try-remove
   #:unfold-table
   #:with-vectors))
