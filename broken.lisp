(defpackage :broken
  (:use :common-lisp))

(in-package :broken)

(let ((some-big 'a-big-long-calculation))
  (defparameter *myvalue* some-big))

(defun get-my-value ()
  *myvalue*)
