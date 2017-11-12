(defpackage :cl-data-structures.documentation
  (:use #:cl #:cl-lore))


(in-package #:cl-data-structures.documentation)


(cl-lore.api.syntax:syntax
 cl-lore.extensions.documentation.api
 cl-lore.extensions.sequence-graphs.api)

(cl-lore.api.syntax:define-save-output-function
    build-docs
    ((<documentation-names>) cl-lore.mechanics:<mechanics-html-output-generator> *cl-data-structures*)
    (:output-options (:css cl-lore.mechanics:*mechanics-html-style*)
     :dynamic-binding ((cl-lore.extensions.documentation.protocol:*index* cl-data-structures:*documentation*)))

  ("vars.lisp"
   "manual.lisp"
   "in-depth.lisp")

  @title{CL-DATA-STRUCTURES}
  @include{cl-ds intro}
  @include{cl-ds API}
  @include{cl-ds internals}
  @include{dicts})
