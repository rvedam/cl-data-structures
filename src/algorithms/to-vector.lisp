(in-package #:cl-data-structures.algorithms)


(cl-ds.alg.meta:define-aggregation-function
    to-vector to-vector-function

  (:range &key key element-type force-copy)
  (:range &key (key #'identity) (element-type t) (force-copy t))

  (%vector)

  ((&key element-type &allow-other-keys)
   (setf %vector (make-array 16 :adjustable t
                                :fill-pointer 0
                                :element-type element-type)))
  ((element)
   (vector-push-extend element %vector))

  (%vector))


(defmethod cl-ds.alg.meta:apply-range-function
    ((range vector)
     (function to-vector-function)
     &rest all &key force-copy key element-type
     &allow-other-keys)
  (declare (ignore all))
  (if (and (not force-copy)
           (subtypep element-type (array-element-type range))
           (eq key #'identity))
      range
      (call-next-method)))
