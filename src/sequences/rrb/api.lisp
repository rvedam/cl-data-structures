(in-package #:cl-data-structures.sequences.rrb-vector)


(defclass functional-rrb-vector (cl-ds.common.rrb:rrb-container
                                 cl-ds:functional)
  ())


(defmethod cl-ds:position-modification ((operation cl-ds:put-function)
                                        (container functional-rrb-vector)
                                        location &key value)
  (let ((tail-size (cl-ds.common.rrb:access-tail-size container))
        (tag (cl-ds.common.abstract:make-ownership-tag)))
    (if (eql tail-size +maximum-children-count+)
        (bind ((new-tail (cl-ds.common.rrb:make-node-content))
               ((:values new-root shift-increased)
                (cl-ds.common.rrb:insert-tail container
                                              tag
                                              #'cl-ds.common.rrb:copy-on-write
                                              (cl-ds.common.rrb:access-tail container))))
          (setf (aref new-tail 0) (cl-ds:make-bucket operation container location
                                                     :value value))
          (make 'rrb-vector
                :root new-root
                :tail (cl-ds.common.rrb:make-node-content)
                :ownership-tag tag
                :tail-size 1
                :size (+ +maximum-children-count+
                         (cl-ds.common.rrb:access-size container))
                :tail new-tail
                :shift (if shift-increased
                           (1+ (cl-ds.common.rrb:access-shift container))
                           (cl-ds.common.rrb:access-shift container))))
        (make 'rrb-vector
              :root (cl-ds.common.rrb:access-root container)
              :tail (let ((new-tail (copy-array (cl-ds.common.rrb:access-tail container))))
                      (setf (aref new-tail tail-size)
                            (cl-ds:make-bucket operation
                                               container
                                               location
                                               :value value))
                      new-tail)
              :ownership-tag tag
              :tail-size (1+ tail-size)
              :ownership-tag tag
              :size (cl-ds.common.rrb:access-size container)
              :shift (cl-ds.common.rrb:access-shift container)))))
