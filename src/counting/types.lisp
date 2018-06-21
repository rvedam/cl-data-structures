(in-package #:cl-data-structures.counting)


(defclass apriori-node ()
  ((%type :reader read-type
          :initarg :type
          :initform nil
          :type (or null integer))
   (%locations :reader read-locations
               :initarg :locations
               :type (vector fixnum))
   (%count :reader read-count
           :initarg :count
           :type integer)
   (%sets :reader read-sets
          :writer write-sets
          :type vector
          :initarg :sets
          :initform (vect))
   (%parent :initarg :parent
            :initform nil
            :writer write-parent
            :reader read-parent)))


(defclass apriori-index ()
  ((%root :reader read-root
          :initarg :root)
   (%minimal-support :reader read-minimal-support
                     :initarg :minimal-support)
   (%reverse-mapping :accessor access-reverse-mapping
                     :initform nil)
   (%mapping :accessor access-mapping
             :initform nil)
   (%minimal-frequency :reader read-minimal-frequency
                       :initarg :minimal-frequency)
   (%total-size :reader read-total-size
                :initarg :total-size)))


(defclass set-in-index ()
  ((%node :initarg :node
          :type (or null apriori-node)
          :reader read-node)
   (%index :initarg :index
           :initform nil
           :type apriori-index
           :reader read-index)))


(defclass apriori-set (set-in-index)
  ((%apriori-node :initarg :apriori-node
                  :reader read-apriori-node
                  :initform nil
                  :type (or null apriori-node))))


(defclass empty-mixin ()
  ())


(defclass empty-set-in-index (empty-mixin set-in-index)
  ())


(defclass empty-apriori-set (empty-mixin apriori-set)
  ())


(defmethod initialize-instance :after ((node apriori-node)
                                       &key &allow-other-keys)
  (when (slot-boundp node '%locations)
    (setf (slot-value node '%count)
          (length (read-locations node)))))