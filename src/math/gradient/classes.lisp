(in-package :cl-data-structures.math.gradient)


(defstruct tape-node
  (symbol nil :type symbol)
  (depends
   (make-array 0 :element-type 'fixnum
                 :initial-element 0)
   :type (simple-array fixnum (*)))
  (weights
   (make-array 0 :element-type 'double-float
                 :initial-element 0.0d0)
   :type (simple-array double-float (*))))


(defclass gradient-expression ()
  ((%nodes :initarg :nodes
           :reader read-nodes)
   (%variables :initarg :variables
               :reader read-variables))
  (:metaclass closer-mop:funcallable-standard-class))


(defmethod initialize-instance :after ((obj gradient-expression) &rest all)
  (declare (ignore all))
  (closer-mop:set-funcallable-instance-function obj (curry #'gradient obj)))