#|
  This file is a part of cl-prolog2.gprolog project.
  Copyright (c) 2017 Masataro Asai (guicho2.71828@gmail.com)
|#

(in-package :cl-user)
(defpackage cl-prolog2.gprolog
  (:use :cl :cl-prolog2)
  (:export
   #:gprolog-prolog))
(in-package :cl-prolog2.gprolog)

;; blah blah blah.

;; broken, don't use.
#+(or)
(defmethod run-prolog ((rules list) (prolog-designator (eql :gprolog-interpreted)) &key debug args (input *standard-input*) (output :string) (error *error-output*) &allow-other-keys)
  (with-temp (d :directory t :debug debug)
    (with-temp (input-file :tmpdir d :template "XXXXXX.prolog" :debug debug)
      (with-open-file (s input-file :direction :output :if-does-not-exist :error)
        (let ((*debug-prolog* debug))
          (dolist (r rules)
            (print-rule s r))))
      (let ((command `("gprolog" "--init-goal" ,(format nil "consult('~a')" input-file) ,@args)))
        (when debug
          (format *error-output* "; ~{~s~^ ~}" command))
        (let* ((out (alexandria:unwind-protect-case ()
                        (uiop:run-program command
                                          :input input
                                          :output output
                                          :error error)
                      (:abort 
                       (format *error-output* "~&; command was: ~{~s~^ ~}" command)
                       (setf debug t))))
               ;; skip lines for byte-code compilation
               (pos (loop with count = 0
                       until (= count 2)
                       for i from 0
                       do
                         (when (char= (aref out i) #\Newline)
                           (incf count))
                       finally (return i))))
          (make-array (- (length out) pos 1)
                      :element-type 'character
                      :displaced-to out
                      :displaced-index-offset (1+ pos)))))))

(defmethod run-prolog ((rules list) (prolog-designator (eql :gprolog)) &key debug args (input *standard-input*) (output :string) (error *error-output*) &allow-other-keys)
  (declare (ignorable args))
  (with-temp (d :directory t :debug debug)
    (with-temp (input-file :tmpdir d :template "XXXXXX.prolog" :debug debug)
      (with-open-file (s input-file :direction :output :if-does-not-exist :error)
        (let ((*debug-prolog* debug))
          (dolist (r rules)
            (print-rule s r))))
      (let* ((executable (namestring (make-pathname :type "out" :defaults input-file)))
             (compiler-command `("gplc" ,input-file "-o" ,executable))
             (command `(,executable)))

        (when debug
          (format *error-output* "~&; ~{~s~^ ~}" compiler-command))
        (alexandria:unwind-protect-case ()
            (uiop:run-program compiler-command :output t :error t)
          (:abort 
           (format *error-output* "~&; command was: ~{~s~^ ~}" compiler-command)
           (setf debug t)))

        (when debug
          (format *error-output* "~&; ~{~s~^ ~}" command))
        
        (string-trim '(#\Space #\Newline #\Return)
                     (alexandria:unwind-protect-case ()
                         (uiop:run-program command 
                                           :input input
                                           :output output
                                           :error error)
                       (:abort 
                        (format *error-output* "~&; command was: ~{~s~^ ~}" command)
                        (setf debug t))))))))