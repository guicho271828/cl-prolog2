(defsystem cl-prolog.bprolog
  :version "0.1"
  :author "Masataro Asai"
  :mailto "guicho2.71828@gmail.com"
  :license "LLGPL"
  :depends-on (:cl-prolog)
  :components ((:file "package"))
  :description "CL-PROLOG extension for BProlog, a high-performance commercial prolog."
  :in-order-to ((test-op (test-op :cl-prolog.bprolog.test)))
  :defsystem-depends-on (:trivial-package-manager)
  :perform
  (load-op :before (op c)
           (format t "~&**** BProlog is a commercial software by Afany Software, but is free for academic/research use. ***~%")
           (uiop:symbol-call :trivial-package-manager
                             :ensure-program
                             "bp"
                             :env-alist `(("PATH" . ,(format nil "~a:~a"
                                                             (asdf:system-relative-pathname
                                                              :cl-prolog.bprolog "BProlog/")
                                                             (uiop:getenv "PATH"))))
                             :from-source (format nil "make -C ~a"
                                                  (asdf:system-source-directory :cl-prolog.bprolog)))))
