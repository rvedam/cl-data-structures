(in-package #:cl-data-structures)

(defgeneric frozenp (obj))

(defun ensure-not-frozen (obj)
  (when (frozenp obj)
    (error 'ice-error :test "Trying to change frozen object!")))

(defmethod position-modification :before (operation
                                          (container transactional)
                                          location
                                          &rest all
                                          &key &allow-other-keys)
  (declare (ignore operation location all))
  (ensure-not-frozen container))

(defgeneric at (container location &rest more-locations))

(defgeneric (setf at) (new-value container location &rest more-locations)
  (:generic-function-class cl-ds.meta:insert!-function))

(defgeneric add (container location new-value)
  (:generic-function-class cl-ds.meta:functional-add-function))

(defgeneric put (container item)
  (:generic-function-class cl-ds.meta:functional-put-function))

(defgeneric take-out! (container)
  (:generic-function-class cl-ds.meta:take-out!-function))

(defgeneric take-out (container)
  (:generic-function-class cl-ds.meta:functional-take-out-function))

(defgeneric near (container item maximal-distance))

(defgeneric add! (container location new-value)
  (:generic-function-class cl-ds.meta:add!-function))

(defgeneric insert (container location new-value)
  (:generic-function-class cl-ds.meta:functional-insert-function))

(defgeneric erase (container location)
  (:generic-function-class cl-ds.meta:functional-erase-function))

(defgeneric erase-if (container location condition-fn)
  (:generic-function-class cl-ds.meta:functional-erase-if-function))

(defgeneric erase-if! (container location condition-fn)
  (:generic-function-class cl-ds.meta:erase-if!-function))

(defgeneric erase! (container location)
  (:generic-function-class cl-ds.meta:erase!-function))

(defgeneric put! (container item)
  (:generic-function-class cl-ds.meta:put!-function))

(defgeneric size (container))

(defgeneric update (container location new-value)
  (:generic-function-class cl-ds.meta:functional-update-function))

(defgeneric update-if (container location new-value condition-fn)
  (:generic-function-class cl-ds.meta:functional-update-if-function))

(defgeneric update! (container location new-value)
  (:generic-function-class cl-ds.meta:update!-function))

(defgeneric update-if! (container location new-value condition-fn)
  (:generic-function-class cl-ds.meta:update-if!-function))

(defgeneric become-functional (container)
  (:method ((container functional)) container))

(defgeneric become-mutable (container)
  (:method ((container mutable)) container))

(defgeneric become-transactional (container))

(defgeneric become-lazy (container))

(defgeneric mutablep (container)
  (:method ((container mutable)) t)
  (:method ((container fundamental-container)) nil))

(defgeneric functionalp (container)
  (:method ((container functional)) t)
  (:method ((container fundamental-container)) nil))

(defgeneric transactionalp (container)
  (:method ((container transactional)) t)
  (:method ((container fundamental-container)) nil))

(defgeneric value (status))

(defgeneric found (status))

(defgeneric empty-clone (container))

(defgeneric traverse (function object)
  (:method (function (object sequence))
    (map nil function object))
  (:method (function (object fundamental-range))
    (iterate
      (for (values val more) = (cl-ds:consume-front object))
      (while more)
      (funcall function val))))

(defgeneric across (function object)
  (:method (function (object sequence))
    (map nil function object))
  (:method (function (object fundamental-container))
    (traverse function object))
  (:method (function (object fundamental-range))
    (traverse function (clone object))))

(defgeneric make-from-traversable (class traversable &rest arguments))

(defgeneric make-of-size (class size &rest more))

#|

Range releated functions.

|#

(defgeneric consume-front (range))

(defgeneric peek-front (range))

(defgeneric (setf peek-front) (new-value range))

(defgeneric consume-back (range))

(defgeneric peek-back (range))

(defgeneric (setf peek-back) (new-value range))

(defgeneric dimensionality (object)
  (:method ((object fundamental-container))
    1)
  (:method ((object fundamental-range))
    1))

(defgeneric drop-front (range count)
  (:method ((range fundamental-forward-range) count)
    (check-type count non-negative-fixnum)
    (iterate
      (repeat count)
      (for i from 0)
      (for (values value more) = (consume-front range))
      (while more)
      (finally (return i)))))

(defgeneric drop-back (range count)
  (:method ((range fundamental-bidirectional-range) count)
    (check-type count non-negative-fixnum)
    (iterate
      (repeat count)
      (for i from 0)
      (for (values value more) = (consume-back range))
      (while more)
      (finally (return i)))))

(defgeneric clone (range))

(defgeneric whole-range (container)
  (:method ((range fundamental-range))
    range))

(defgeneric reset! (obj))

(defmethod cl-ds.meta:functional-counterpart ((operation cl-ds.meta:functional-function))
  operation)

(defmethod cl-ds.meta:functional-counterpart ((operation cl-ds.meta:erase!-function))
  #'erase)

(defmethod cl-ds.meta:functional-counterpart ((operation cl-ds.meta:update-if!-function))
  #'update-if)

(defmethod cl-ds.meta:functional-counterpart ((operation cl-ds.meta:erase-if!-function))
  #'erase-if)

(defmethod cl-ds.meta:functional-counterpart ((operation cl-ds.meta:put!-function))
  #'put)

(defmethod cl-ds.meta:functional-counterpart ((operation cl-ds.meta:add!-function))
  #'add)

(defmethod cl-ds.meta:functional-counterpart ((operation cl-ds.meta:insert!-function))
  #'insert)

(defmethod cl-ds.meta:functional-counterpart ((operation cl-ds.meta:take-out!-function))
  #'take-out)

(defmethod cl-ds.meta:functional-counterpart ((operation cl-ds.meta:update!-function))
  #'update)

(defmethod cl-ds.meta:destructive-counterpart ((operation cl-ds.meta:destructive-function))
  operation)

(defmethod cl-ds.meta:destructive-counterpart ((operation cl-ds.meta:functional-erase-function))
  #'erase!)

(defmethod cl-ds.meta:destructive-counterpart ((operation cl-ds.meta:functional-erase-if-function))
  #'erase-if!)

(defmethod cl-ds.meta:destructive-counterpart ((operation cl-ds.meta:functional-update-if-function))
  #'update-if!)

(defmethod cl-ds.meta:destructive-counterpart ((operation cl-ds.meta:functional-add-function))
  #'add!)

(defmethod cl-ds.meta:destructive-counterpart ((operation cl-ds.meta:functional-put-function))
  #'put!)

(defmethod cl-ds.meta:destructive-counterpart ((operation cl-ds.meta:functional-insert-function))
  #'(setf at))

(defmethod cl-ds.meta:destructive-counterpart ((operation cl-ds.meta:functional-take-out-function))
  #'take-out!)

(defmethod cl-ds.meta:destructive-counterpart ((operation cl-ds.meta:functional-update-function))
  #'update!)
