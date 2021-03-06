(in-package #:cl-ds.utils.cluster)

(locally (declare (optimize (debug 3)))
  (defclass pam-algorithm-state ()
    ((%input-data :initarg :input-data
                  :accessor access-input-data)
     (%number-of-medoids :initarg :number-of-medoids
                         :type positive-integer
                         :accessor access-number-of-medoids)
     (%distance-matrix :initarg :distance-matrix
                       :type cl-ds.utils:half-matrix
                       :accessor access-distance-matrix)
     (%select-medoids-attempts-count :initarg :select-medoids-attempts-count
                                     :accessor access-select-medoids-attempts-count
                                     :initform 20)
     (%split-merge-attempts-count :initarg :split-merge-attempts-count
                                  :type non-negative-fixnum
                                  :accessor access-split-merge-attempts-count
                                  :initform 0)
     (%split-threshold :initarg :split-threshold
                       :accessor access-split-threshold
                       :initform nil)
     (%merge-threshold :initarg :merge-threshold
                       :accessor access-merge-threshold
                       :initform nil)
     (%unfinished-clusters :initarg :improvements
                           :accessor access-unfinished-clusters)
     (%cluster-size :initarg :cluster-size
                    :type non-negative-fixnum
                    :accessor access-cluster-size)
     (%indexes :initarg :indexes
               :type (vector non-negative-fixnum)
               :accessor access-indexes)
     (%cluster-contents :initarg :cluster-contents
                        :type vector
                        :accessor access-cluster-contents)))


  (defclass clara-algorithm-state (pam-algorithm-state)
    ((%result-cluster-contents :initform nil
                               :type (or null vector)
                               :accessor access-result-cluster-contents)
     (%all-indexes :accessor access-all-indexes
                   :type (vector non-negative-fixnum))
     (%metric-type :initarg :metric-type
                   :accessor access-metric-type
                   :type (or symbol list))
     (%metric-fn :initarg :metric-fn
                 :accessor access-metric-fn
                 :type function)
     (%sample-count :initarg :sample-count
                    :accessor access-sample-count
                    :type positive-integer)
     (%key :initarg :key
           :accessor access-key
           :type function)
     (%index-mapping :initform nil
                     :accessor access-index-mapping
                     :type (or null (simple-array non-negative-fixnum (*))))
     (%sample-size :initarg :sample-size
                   :type positive-integer
                   :accessor access-sample-size)
     (%mean-silhouette :initform -10 ; silhouette is bound by definition in -1 to +1
                       :type number
                       :accessor access-mean-silhouette)
     (%silhouette :initform nil
                  :type (or null (vector number))
                  :accessor access-silhouette)))


  (defclass clustering-result ()
    ((%cluster-contents :initarg :cluster-contents
                        :type vector
                        :reader read-cluster-contents)
     (%silhouette :initarg :silhouette
                  :type (vector number)
                  :reader read-silhouette))))


(defun empty-clustering-result ()
  (make 'clustering-result
        :cluster-content #()
        :silhouette (make-array 0 :element-type 'number)))


(cl-ds.utils:define-list-of-slots pam-algorithm-state
  (%input-data access-input-data)
  (%number-of-medoids access-number-of-medoids)
  (%distance-matrix access-distance-matrix)
  (%split-merge-attempts-count access-split-merge-attempts-count)
  (%split-threshold access-split-threshold)
  (%merge-threshold access-merge-threshold)
  (%unfinished-clusters access-unfinished-clusters)
  (%select-medoids-attempts-count access-select-medoids-attempts-count)
  (%cluster-contents access-cluster-contents)
  (%indexes access-indexes)
  (%cluster-size access-cluster-size))


(cl-ds.utils:define-list-of-slots clara-algorithm-state
  (%input-data access-input-data)
  (%number-of-medoids access-number-of-medoids)
  (%distance-matrix access-distance-matrix)
  (%split-merge-attempts-count access-split-merge-attempts-count)
  (%split-threshold access-split-threshold)
  (%merge-threshold access-merge-threshold)
  (%unfinished-clusters access-unfinished-clusters)
  (%select-medoids-attempts-count access-select-medoids-attempts-count)
  (%indexes access-indexes)
  (%cluster-size access-cluster-size)
  (%metric-fn access-metric-fn)
  (%metric-type access-metric-type)
  (%sample-size access-sample-size)
  (%cluster-contents access-cluster-contents)
  (%silhouette access-silhouette)
  (%key access-key)
  (%index-mapping access-index-mapping)
  (%sample-count access-sample-count)
  (%all-indexes access-all-indexes)
  (%result-cluster-contents access-result-cluster-contents)
  (%mean-silhouette access-mean-silhouette))


(defun restart-pam (object)
  (declare (optimize (safety 3) (debug 3)))
  (cl-ds.utils:with-slots-for (object pam-algorithm-state)
    (if (zerop %split-merge-attempts-count)
        (progn (assert (null %merge-threshold))
               (assert (null %split-threshold)))
        (assert (< 0 %merge-threshold %split-threshold)))
    (macrolet ((slot-initialized-p (slot)
                 `(and (slot-boundp object ',slot)
                       (not (null ,slot)))))
      (unless (slot-initialized-p %indexes)
        (setf %indexes (coerce (~> %input-data length iota)
                               '(vector non-negative-fixnum))))
      (let ((length (length %indexes)))
        (setf %number-of-medoids
              (if (slot-initialized-p %number-of-medoids)
                  (max (min %number-of-medoids length) 1)
                  length))
        (if (slot-initialized-p %cluster-size)
            (assert (< 0 %cluster-size))
            (setf %cluster-size (max 2 (round-to (/ length %number-of-medoids)
                                                 2))))
        (unless (slot-initialized-p %cluster-contents)
          (setf %cluster-contents (make-array %number-of-medoids
                                              :adjustable t
                                              :fill-pointer %number-of-medoids))
          (map-into %cluster-contents
                    (lambda () (make-array %cluster-size :adjustable t
                                                    :fill-pointer 1))))
        (unless (slot-initialized-p %unfinished-clusters)
          (setf %unfinished-clusters
                (make-array %number-of-medoids
                            :element-type 'boolean
                            :adjustable t
                            :fill-pointer %number-of-medoids
                            :initial-element nil)))))))


(defmethod initialize-instance :after ((object pam-algorithm-state)
                                       &key &allow-other-keys)
  (restart-pam object))


(defmethod initialize-instance :after ((object clara-algorithm-state)
                                       &key &allow-other-keys)
  (cl-ds.utils:with-slots-for (object clara-algorithm-state)
    (setf %all-indexes %indexes)
    (setf %sample-size (min (length %indexes) %sample-size))
    (setf %index-mapping (make-array (length %indexes)
                                     :element-type 'non-negative-fixnum))))


(defun clone-state (state &key indexes)
  (lret ((result (make 'pam-algorithm-state
                       :input-data (access-input-data state)
                       :indexes indexes
                       :clusters nil
                       :unfinished-clusters nil
                       :distance-matrix (access-distance-matrix state))))
    (assert (not (emptyp (access-indexes state))))))
