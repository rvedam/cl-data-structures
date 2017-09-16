(in-package #:cl-data-structures)


(defclass functional-function ()
  ())


(defclass destructive-function ()
  ())


(defclass grow-function ()
  ())


(defclass shrink-function ()
  ())


(defclass insert-function (grow-function)
  ())


(defclass update-function (grow-function)
  ())


(defclass add-function (grow-function)
  ())


(defclass erase-function (shrink-function)
  ())


(defclass functional-insert-function (closer-mop:standard-generic-function
                                      functional-function
                                      insert-function)
  ()
  (:metaclass closer-mop:funcallable-standard-class))


(defclass functional-update-function (closer-mop:standard-generic-function
                                      functional-function
                                      update-function)
  ()
  (:metaclass closer-mop:funcallable-standard-class))


(defclass functional-add-function (closer-mop:standard-generic-function
                                   functional-function
                                   add-function)
  ()
  (:metaclass closer-mop:funcallable-standard-class))


(defclass functional-erase-function (closer-mop:standard-generic-function
                                     functional-function
                                     erase-function)
  ()
  (:metaclass closer-mop:funcallable-standard-class))


(defclass insert!-function (closer-mop:standard-generic-function
                            destructive-function
                            insert-function)
  ()
  (:metaclass closer-mop:funcallable-standard-class))


(defclass update!-function (closer-mop:standard-generic-function
                            destructive-function
                            update-function)
  ()
  (:metaclass closer-mop:funcallable-standard-class))


(defclass add!-function (closer-mop:standard-generic-function
                         destructive-function
                         add-function)
  ()
  (:metaclass closer-mop:funcallable-standard-class))


(defclass erase!-function (closer-mop:standard-generic-function
                           destructive-function
                           erase-function)
  ()
  (:metaclass closer-mop:funcallable-standard-class))


(defgeneric grow-bucket (operation container bucket location
                         &key &allow-other-keys))


(defgeneric shrink-bucket (operation container bucket location
                           &key &allow-other-keys))


(defgeneric make-bucket (operation container location
                         &key &allow-other-keys))


(defgeneric grow-bucket! (operation container bucket location
                          &key &allow-other-keys))


(defgeneric shrink-bucket! (operation container bucket location
                            &key &allow-other-keys))