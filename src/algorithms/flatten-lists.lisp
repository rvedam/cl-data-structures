(in-package #:cl-data-structures.algorithms)


(defclass flatten-proxy (proxy-range)
  ((%key :initarg :key
         :reader read-key)
   (%current :initform nil
             :initarg :current
             :accessor access-current)))


(defclass forward-flatten-proxy (flatten-proxy
                                 fundamental-forward-range)
  ())


(defmethod cl-ds:clone ((range flatten-proxy))
  (make (type-of range)
        :key (read-key range)
        :current (access-current range)
        :original-range (read-original-range range)))


(defmethod cl-ds:traverse (function (range flatten-proxy))
  (labels ((impl (x)
             (if (listp x)
                 (map nil #'impl x)
                 (funcall function x))))
    (declare (dynamic-extent (function impl)))
    (cl-ds:traverse #'impl (read-original-range range))
    range))


(defmethod cl-ds:across (function (range flatten-proxy))
  (labels ((impl (x)
             (if (listp x)
                 (map nil #'impl x)
                 (funcall function x))))
    (declare (dynamic-extent (function impl)))
    (cl-ds:across #'impl (read-original-range range))
    range))


(defmethod cl-ds:reset! ((range flatten-proxy))
  (setf (access-current range) nil)
  (call-next-method))


(defmethod cl-ds:peek-front ((range forward-flatten-proxy))
  (bind ((key (read-key range))
         (current (access-current range))
         ((:labels value (element))
          (cond ((null element) nil)
                ((atom element) element)
                ((listp element)
                 (iterate
                   (for elt in element)
                   (for result = (value elt))
                   (until result)
                   (finally (return result))))))
         (result (value current)))
    (if (null result)
        (bind ((fresh-clone (cl-ds:clone (read-original-range range))))
          (iterate
            (for (values value more) = (cl-ds:consume-front fresh-clone))
            (when (not more)
              (leave (values nil nil)))
            (for result = (value (funcall key value)))
            (unless (null result)
              (leave (values result t)))))
        (values result t))))


(defmethod cl-ds:consume-front ((range forward-flatten-proxy))
  (bind ((key (read-key range))
         ((:accessors (current access-current)) range)
         ((:labels value ())
          (cond ((null current) nil)
                ((atom current) (progn (setf current nil)
                                       current))
                ((listp current)
                 (iterate
                   (for elt = (first current))
                   (setf current (rest current))
                   (cond ((listp elt)
                          (setf current (append elt current)))
                         ((atom elt)
                          (leave elt)))
                   (until (null current))))))
         (result (value)))
    (if (null result)
        (iterate
          (with outer = (read-original-range range))
          (for (values value more) = (cl-ds:consume-front outer))
          (when (not more)
            (leave (values nil nil)))
          (setf current (funcall key value))
          (for result = (value))
          (unless (null result)
            (leave (values result t))))
        (values result t))))


(defclass flatten-aggregator (cl-ds.alg.meta:fundamental-aggregator)
  ((%key :initarg :key
         :reader read-key)
   (%outer :initarg :outer
           :reader read-outer)))

(defmethod proxy-range-aggregator-outer-fn ((range flatten-proxy)
                                            key
                                            function
                                            outer-fn
                                            arguments)
  (bind (((:slots (%key cl-ds.alg.meta:%key) %function) range)
         (outer-fn (call-next-method)))
    (lambda ()
      (let ((outer (funcall outer-fn)))
        (make 'flatten-aggregator
              :key (read-key range)
              :outer outer)))))


(defmethod cl-ds.alg.meta:construct-aggregator ((range flatten-proxy)
                                                key
                                                (function cl-ds.alg.meta:aggregation-function)
                                                outer-fn
                                                (arguments list))
  (cl-ds.alg.meta:construct-aggregator
   (read-original-range range)
   (read-key range)
   function
   (proxy-range-aggregator-outer-fn range
                                    key
                                    function
                                    outer-fn
                                    arguments)
   arguments))


(defmethod cl-ds.alg.meta:pass-to-aggregation ((aggregator flatten-aggregator)
                                               element)
  (labels ((to-outer (element)
             (if (listp element)
                 (map nil #'to-outer element)
                 (cl-ds.alg.meta:pass-to-aggregation (read-outer aggregator)
                                                     element))))
    (declare (dynamic-extent (function to-outer)))
    (to-outer (funcall (read-key aggregator) element))))


(defmethod cl-ds.alg.meta:aggregator-finished-p ((aggregator flatten-aggregator))
  (cl-ds.alg.meta:aggregator-finished-p (read-outer aggregator)))


(defmethod cl-ds.alg.meta:end-aggregation ((aggregator flatten-aggregator))
  (cl-ds.alg.meta:end-aggregation (read-outer aggregator)))


(defmethod cl-ds.alg.meta:begin-aggregation ((aggregator flatten-aggregator))
  (cl-ds.alg.meta:begin-aggregation (read-outer aggregator)))


(defmethod cl-ds.alg.meta:extract-result ((aggregator flatten-aggregator))
  (cl-ds.alg.meta:extract-result (read-outer aggregator)))


(defmethod cl-ds.alg.meta:expects-content-p ((aggregator flatten-aggregator))
  (cl-ds.alg.meta:expects-content-p (read-outer aggregator)))


(defclass flatten-lists-function (layer-function)
  ()
  (:metaclass closer-mop:funcallable-standard-class))


(defgeneric flatten-lists (range &key key)
  (:generic-function-class flatten-lists-function)
  (:method (range &key (key #'identity))
    (apply-range-function range #'flatten-lists :key key)))


(defmethod apply-layer ((range fundamental-forward-range)
                        (function flatten-lists-function)
                        &rest all &key key)
  (declare (ignore all))
  (make 'forward-flatten-proxy
        :key key
        :original-range range))
