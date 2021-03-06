(in-package #:cl-user)
(defpackage expression-tests
  (:use :cl :prove :serapeum :cl-ds :iterate :alexandria)
  (:shadowing-import-from :iterate :collecting :summing :in))
(in-package #:expression-tests)

(plan 5)
(let ((data nil)
      (expression (cl-ds:xpr (:iteration 1)
                    (when (< iteration 5)
                      (send-recur iteration :iteration (1+ iteration))))))
  (is (cl-ds:peek-front expression) 1)
  (cl-ds:across (lambda (x) (push x data))
                expression)
  (is data '(4 3 2 1) :test #'equal)
  (setf data nil)
  (iterate
    (for (values value not-finished) = (funcall expression))
    (while not-finished)
    (push value data))
  (is data '(4 3 2 1) :test #'equal))

(let* ((data '(1 2 (3 4) (5 (6 7))))
       (expression (cl-ds:xpr (:stack (list data))
                     (unless (endp stack)
                       (let ((front (first stack)))
                         (cond ((atom front)
                                (send-recur front :stack (rest stack)))
                               (t (recur :stack (append front (rest stack))))))))))
  (let ((result nil))
    (cl-ds:traverse (lambda (x) (push x result)) expression)
    (is (sort result #'<) '(1 2 3 4 5 6 7) :test #'equal)))

(let* ((data '(1 2 (3 4) (5 (6 7))))
       (expression (cl-ds:xpr (:stack (list data))
                     (unless (endp stack)
                       (destructuring-bind (front . stack) stack
                         (cond ((atom front)
                                (send-recur front :stack stack))
                               (t (recur :stack (iterate
                                                  (for elt in front)
                                                  (push elt stack)
                                                  (finally (return stack)))))))))))
  (let ((result nil))
    (cl-ds:traverse (lambda (x) (push x result)) expression)
    (is (sort result #'<) '(1 2 3 4 5 6 7) :test #'equal)))

(finalize)
