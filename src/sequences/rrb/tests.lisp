(in-package :cl-user)
(defpackage rrb-vector-tests (:use :prove))
(in-package :rrb-vector-tests)
(cl-ds.utils:import-all-package-symbols :cl-data-structures.sequences.rrb-vector :rrb-vector-tests)

(plan 142)
(let* ((container (make-instance 'functional-rrb-vector))
       (cont1 (cl-ds:put container 1))
       (cont2 (cl-ds:put cont1 2)))
  (ok (cl:subtypep (type-of container) 'cl-ds:traversable))
  (is (cl-ds:at cont2 0) 1)
  (is (cl-ds:at cont2 1) 2)
  (setf container cont2)
  (iterate
    (for i from 3)
    (repeat cl-data-structures.common.rrb:+maximum-children-count+)
    (setf container (cl-ds:put container i)))
  (is (cl-ds:size container) 34)
  (iterate
    (for i from 3)
    (repeat cl-data-structures.common.rrb:+maximum-children-count+)
    (is (cl-ds:at container (1- i)) i))
  (let ((content cl:nil))
    (cl-ds:traverse (lambda (x) (push x content))
                    container)
    (is (reverse content) (alexandria:iota 34 :start 1)))
  (let ((range (cl-ds:whole-range container)))
    (iterate
      (for i from 0 below 34)
      (is (cl-ds:at range i) (1+ i))))
  (let ((range (cl-ds:whole-range container)))
    (iterate
      (for (values value not-end) = (cl-ds:consume-front range))
      (for i from 1)
      (while not-end)
      (is value i)))
  (let ((range (cl-ds:whole-range container)))
    (iterate
      (for (values value not-end) = (cl-ds:consume-back range))
      (for i from 34 downto 0)
      (while not-end)
      (is value i)))
  (setf container (cl-ds:update container 10 'a))
  (is (cl-ds:at container 10) 'a)
  (setf container (cl-ds:take-out container))
  (is (cl-ds:size container) 33)
  (setf container (cl-ds:take-out container))
  (is (cl-ds:size container) 32)
  (setf container (cl-ds:take-out container))
  (is (cl-ds:size container) 31))
(finalize)
