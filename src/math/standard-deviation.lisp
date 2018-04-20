(in-package #:cl-data-structures.math)


(defclass standard-deviation-function (cl-ds.alg.meta:multi-aggregation-function)
  ()
  (:metaclass closer-mop:funcallable-standard-class))


(defgeneric standard-deviation (range &key key biased)
  (:generic-function-class standard-deviation-function)
  (:method (range &key key (biased t))
    (cl-ds.alg.meta:apply-aggregation-function range
                                               #'standard-deviation
                                               :key key
                                               :biased biased)))


(defmethod cl-ds.alg.meta:multi-aggregation-stages ((fn standard-deviation-function)
                                                    &rest all
                                                    &key key biased
                                                    &allow-other-keys)
  (declare (ignore all))
  `((:average . ,(lambda (range)
                   (average range :key key)))
    (:variance . ,(lambda (range)
                    (variance range :key key :biased biased)))))


(defmethod cl-ds.alg.meta:make-state ((function standard-deviation-function)
                                 &rest all &key variance
                                 &allow-other-keys)
  (declare (ignore all))
  (sqrt variance))
