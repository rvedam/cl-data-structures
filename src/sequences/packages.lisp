(in-package #:cl-user)


(defpackage :cl-data-structures.sequences
  (:use #:common-lisp #:serapeum #:cl-ds.utils
        #:alexandria #:iterate #:metabang-bind)
  (:shadowing-import-from #:iterate #:collecting #:summing #:in)
  (:nicknames #:cl-ds.seqs)
  (:export
   #:fundamental-sequence
   #:functional-sequence
   #:mutable-sequence
   #:transactional-sequence))


(defpackage :cl-data-structures.sequences.rrb-vector
  (:use #:common-lisp #:iterate #:alexandria #:serapeum #:cl-ds.utils
        #:metabang-bind #:cl-data-structures.common.hamt)
  (:nicknames #:cl-ds.seqs.rrb)
  (:shadowing-import-from #:iterate #:collecting #:summing #:in)
  (:export
   #:functional-rrb-vector
   #:make-functional-rrb-vector
   #:make-mutable-rrb-vector
   #:make-transactional-rrb-vector
   #:mutable-rrb-vector
   #:transactional-rrb-vector))
