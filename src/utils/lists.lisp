(in-package #:cl-data-structures.utils)


(-> insert-or-replace (list t &key
                            (:test (-> (t t) boolean))
                            (:list-key (-> (t) t))
                            (:item-key (-> (t) t))
                            (:preserve-order boolean))
    (values list boolean t))
(declaim (inline insert-or-replace))
(defun insert-or-replace (list element &key
                                         (test #'eql)
                                         (list-key #'identity)
                                         (item-key #'identity)
                                         (preserve-order nil))
  (declare (optimize (speed 3) (safety 0) (debug 0) (space 0)))
  "Insert element into set if it is not already here.

   @b(Returns three values:)
   @begin(list)
    @item(first -- new list)
    @item(second -- was any item replaced?)
    @item(third -- old value that was replaced (or nil if there was no such value))
   @end(list)"
  (iterate
    (with last-cell = nil)
    (with result = nil)
    (with replaced = nil)
    (with value = nil)
    (for sublist on list)
    (for elt = (car sublist))
    (if (funcall test (funcall list-key elt) (funcall item-key element))
        (progn
          (push element result)
          (setf replaced t
                value elt))
        (push elt result))
    (unless last-cell
      (setf last-cell result))
    (when (and replaced last-cell (not preserve-order))
      (setf (cdr last-cell)
            (cdr sublist))
      (finish))
    (finally (return (values (let ((r (if preserve-order
                                          (nreverse result)
                                          result)))
                               (if replaced
                                   r
                                   (cons element
                                         r)))
                             replaced
                             value)))))


(-> try-remove (t list &key
                  (:test (-> (t t) boolean))
                  (:key (-> (t) t))
                  (:preserve-order boolean))
    (values list boolean t))
(declaim (inline try-remove))
(defun try-remove (item list &key (test #'eql) (key #'identity) (preserve-order nil))
  (declare (optimize (speed 3) (safety 0) (debug 0) (space 0)))
  "Try to remove first item matching from the list.

   @b(Returns three values:)
   @begin(list)
    @item(first -- new list)
    @item(second -- did anything was removed?)
    @item(third -- value that was removed (or nil if nothing was removed))
   @end(list)"
  (iterate
    (for sublist on list)
    (for elt = (car sublist))
    (with removed = nil)
    (with value = nil)
    (with last-cell = nil)
    (if (funcall test
                 (funcall key elt)
                 item)
        (setf removed t
              value elt)
        (collect elt into result at start))
    (unless last-cell
      (setf last-cell result))
    (when (and removed last-cell (not preserve-order))
      (setf (cdr last-cell) (cdr sublist))
      (finish))
    (finally (return (values (if preserve-order
                                 (reverse result)
                                 result)
                             removed
                             value)))))


(-> try-find-cell (t list &key (:test (-> (t t) boolean)) (:key (-> (t) t))) list)
(defun try-find-cell (item list &key (test #'eql) (key #'identity))
  (declare (optimize (speed 3) (safety 0) (debug 0) (space 0)))
  "@b(Returns) first matching sublist"
  (iterate
    (for elt on list)
    (when (funcall test
                   (funcall key (car elt))
                   item)
      (leave elt))))


(-> try-find-cell (t list &key (:test (-> (t t) boolean)) (:key (-> (t) t))) (values t boolean))
(defun try-find (item list &key (test #'eql) (key #'identity))
  (declare (optimize (speed 3) (safety 0) (debug 0) (space 0)))
  "@b(Returns) first matching elements as first value and boolean telling if it was found as second"
  (let ((r (try-find-cell item list :test test :key key)))
    (values (car r)
            (not (null r)))))


(defun lexicographic-compare (compare same av bv &key (key #'identity))
  (setf compare (alexandria:ensure-function compare))
  (setf same (alexandria:ensure-function same))
  (check-type av sequence)
  (check-type bv sequence)
  (check-type compare function)
  (check-type same function)
  (iterate
    (for ea1 in-sequence av)
    (for eb1 in-sequence bv)
    (for ea = (funcall key ea1))
    (for eb = (funcall key eb1))
    (for sm = (funcall same ea eb))
    (for comp = (funcall compare ea eb))
    (finding comp such-that comp into r)
    (always sm)
    (finally
     (if r
         (return r)
         (when sm
           (return (< (length av) (length bv))))))))


(defun add-to-list (list data)
  (reduce (flip #'cons)
          data
          :initial-value list))
