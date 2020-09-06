;;; debian-init.el --- Debian utilities

;;; Make sure that we have instrumented all Debian packages

;; Load debian-startup.el and run startup
(unless (boundp 'debian-emacs-flavor)
  (load "debian-startup")
  ;; Now instrument all of the packages
  (defconst debian-emacs-flavor 'emacs-snapshot
    "A symbol representing the particular debian flavor of emacs that's
running.  Something like 'emacs20, 'xemacs20, etc.")
  (debian-startup debian-emacs-flavor))

(add-to-list 'load-path "/usr/share/emacs/site-lisp")
