(in-package #:cl-data-structures.utils)


(defun cartesian (sequence-of-sequences result-callback)
  (unless (some #'emptyp sequence-of-sequences)
    (let* ((l (length sequence-of-sequences))
           (lengths (map '(vector fixnum) #'length sequence-of-sequences))
           (indexes (make-array l :element-type 'fixnum)))
      (iterate
        (for i = (iterate
                   (for i from 0 below l)
                   (finding i such-that (not (eql (1+ (aref indexes i))
                                                  (aref lengths i))))))
        (for p-i previous i initially 0)
        (apply result-callback
               (map 'list #'elt sequence-of-sequences indexes))
        (until (null i))
        (when (not (eql i p-i))
          (iterate (for j from 0 below i)
            (setf (aref indexes j) 0)))
        (incf (aref indexes i))))))
