;;; debian-init.el --- Debian utilities

;; This file is part of Michael Olson's Emacs settings.

;; The code in this file may be used, distributed, and modified
;; without restriction.

;;; Make sure that we have instrumented all Debian packages

;; Load the necessary functions
(unless (boundp 'debian-emacs-flavor)
  (load "debian-startup"))

;; I dislike the way that Debian munges load-path, so don't do any of that.
(defun debian-run-directories (&rest dirs)
  "Load each file of the form XXfilename.el or XXfilename.elc in any
of the dirs, where XX must be a number.  The files will be run in
alphabetical order.  If a file appears in more than one of the dirs,
then the earlier dir takes precedence, and a .elc file always
supercedes a .el file of the same name."
  (let* ((paths dirs)
         ;; Get a list of all the files in all the specified
         ;; directories that match the pattern.
         (files
          (apply 'append
                 (mapcar
                  (lambda (dir)
                    (directory-files dir nil "^[0-9][0-9].*\\.elc?$" t))
                  paths)))
         ;; Now strip the directory portion, remove any .el or .elc
         ;; extension.
         (stripped-names
          (mapcar (lambda (file)
                    (if (string-match "\\.el$" file)
                        (substring file 0 -3)
                      (if (string-match "\\.elc$" file)
                          (substring file 0 -4)
                        file)))
                  (mapcar
                   (lambda (file) (file-name-nondirectory file))
                   files)))
         ;; Deal with init files that use `flavor'
         (flavor debian-emacs-flavor)
         ;; Finally sort them, and delete duplicates
         (base-names (debian-unique-strings (sort stripped-names 'string<))))
    ;; Add the Debian site-start.d paths to load-path
    (setq load-path (nconc (copy-alist paths) load-path))
    ;; Now load the files.  "load" will make sure we get the byte
    ;; compiled one first, if any, and will respect load-path's
    ;; ordering.
    (mapcar
     (lambda (file)
       (condition-case ()
           (load file nil)
         (error (message "Error while loading %s" file))))
     base-names)
    ;; Remove the site-start.d paths
    (setq load-path (delq nil
                          (mapcar (lambda (item)
                                    (if (member item paths) nil
                                      item))
                                  load-path)))))

;; Now instrument all of the packages
(unless (boundp 'debian-emacs-flavor)
  (defconst debian-emacs-flavor 'emacs-snapshot
    "A symbol representing the particular debian flavor of emacs that's
running.  Something like 'emacs20, 'xemacs20, etc.")
  (debian-startup debian-emacs-flavor))

;; Deal with tree-widget.el in slime directory shadowing the built-in
;; version.
(setq load-path
      (nconc (delete
              "/usr/local/share/emacs/23.0.60/site-lisp/slime"
              (delete "/usr/share/emacs-snapshot/site-lisp/slime" load-path))
             (list "/usr/local/share/emacs/23.0.60/site-lisp/slime")))

;;; More Hacks

(defcustom debian-changelog-distributions
  '("unstable" "testing" "testing-security" "stable"
    "stable-security" "oldstable-security" "experimental"
    "UNRELEASED")
  "List of all possible Debian distributions."
  :group 'debian-changelog
  :type '(repeat string))

(defun debian-changelog-distribution ()
  "Delete the current distribution and prompt for a new one."
  (interactive)
  (if (eq (debian-changelog-finalised-p) t)
      (error (substitute-command-keys "most recent version has been finalised - use \\[debian-changelog-unfinalise-last-version] or \\[debian-changelog-add-version]")))
  (let ((str (completing-read
              "Select distribution: "
              (mapcar #'list debian-changelog-distributions)
              nil t nil)))
    (if (not (equal str ""))
        (debian-changelog-setdistribution str))))

;;; Customizations

(add-to-list 'debian-changelog-distributions "hardy")
(add-to-list 'debian-changelog-distributions "intrepid")

;;; debian-init.el ends here
