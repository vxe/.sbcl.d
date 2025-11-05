;;;; project.lisp - Project Management Layer
;;;; Project creation, management, and Quicklisp integration

(in-package #:cl-user)

;;; ============================================================================
;;; Dependencies
;;; ============================================================================

;; Load required systems silently
(handler-case
    (progn
      (ql:quickload :quickproject :silent t)
      (ql:quickload :unix-opts :silent t))
  (error (e)
    (format t "~&; Warning: Could not load project dependencies: ~a~%" e)))

;;; ============================================================================
;;; Project Creation
;;; ============================================================================

(defun new-project (project-name &rest depends-on)
  "Create a new Quicklisp project in local-projects."
  (let ((project-path (merge-pathnames
                       (str "quicklisp/local-projects/" project-name "/")
                       (user-homedir-pathname))))
    (quickproject:make-project
     project-path
     :depends-on depends-on
     :name project-name)
    (format t "~&Created project: ~a~%" project-path)
    (format t "Dependencies: ~{~a~^, ~}~%" depends-on)
    project-path))

(defun new-package (package-name &key (use '(:cl)))
  "Create a new package definition."
  (let ((code (format nil
                      ";;;; ~a.lisp~%~
                       ~%~
                       (defpackage #:~a~%~
                       ~{  (:use #:~(~a~))~%~}~
                         (:export))~%~
                       ~%~
                       (in-package #:~a)~%~
                       ~%~
                       ;;; Your code here~%"
                      package-name
                      package-name
                      use
                      package-name)))
    (format t "~a~%" code)
    code))

(defun scaffold-project (name &key (author "Anonymous") (license "MIT"))
  "Create a fully scaffolded project with common files."
  (let* ((project-path (merge-pathnames
                        (str "quicklisp/local-projects/" name "/")
                        (user-homedir-pathname)))
         (src-path (merge-pathnames "src/" project-path))
         (test-path (merge-pathnames "test/" project-path)))

    ;; Create directories
    (ensure-directories-exist src-path)
    (ensure-directories-exist test-path)

    ;; Create .asd file
    (with-open-file (stream (merge-pathnames (str name ".asd") project-path)
                            :direction :output
                            :if-exists :supersede)
      (format stream ";;;; ~a.asd~%~%" name)
      (format stream "(asdf:defsystem #:~a~%" name)
      (format stream "  :description \"~a\"~%" name)
      (format stream "  :author \"~a\"~%" author)
      (format stream "  :license \"~a\"~%" license)
      (format stream "  :version \"0.0.1\"~%")
      (format stream "  :serial t~%")
      (format stream "  :components ((:module \"src\"~%")
      (format stream "                :components~%")
      (format stream "                ((:file \"package\")~%")
      (format stream "                 (:file \"~a\"))))~%" name)
      (format stream "  :in-order-to ((test-op (test-op \"~a/test\"))))~%~%" name)
      (format stream "(asdf:defsystem #:~a/test~%" name)
      (format stream "  :depends-on (#:~a)~%" name)
      (format stream "  :components ((:module \"test\"~%")
      (format stream "                :components~%")
      (format stream "                ((:file \"~a-test\"))))~%" name)
      (format stream "  :perform (test-op (o c) (symbol-call :~a-test :run-tests)))~%" name))

    ;; Create package file
    (with-open-file (stream (merge-pathnames "package.lisp" src-path)
                            :direction :output
                            :if-exists :supersede)
      (format stream ";;;; package.lisp~%~%")
      (format stream "(defpackage #:~a~%" name)
      (format stream "  (:use #:cl)~%")
      (format stream "  (:export #:main))~%"))

    ;; Create main file
    (with-open-file (stream (merge-pathnames (str name ".lisp") src-path)
                            :direction :output
                            :if-exists :supersede)
      (format stream ";;;; ~a.lisp~%~%" name)
      (format stream "(in-package #:~a)~%~%" name)
      (format stream "(defun main ()~%")
      (format stream "  \"Main entry point\"~%")
      (format stream "  (format t \"Hello from ~a!~~%\"))~%" name))

    ;; Create test file
    (with-open-file (stream (merge-pathnames (str name "-test.lisp") test-path)
                            :direction :output
                            :if-exists :supersede)
      (format stream ";;;; ~a-test.lisp~%~%" name)
      (format stream "(defpackage #:~a-test~%" name)
      (format stream "  (:use #:cl #:~a)~%" name)
      (format stream "  (:export #:run-tests))~%~%")
      (format stream "(in-package #:~a-test)~%~%" name)
      (format stream "(defun run-tests ()~%")
      (format stream "  \"Run all tests\"~%")
      (format stream "  (format t \"Running tests for ~a...~~%\")~%" name)
      (format stream "  (format t \"All tests passed!~~%\"))~%"))

    ;; Create README
    (with-open-file (stream (merge-pathnames "README.md" project-path)
                            :direction :output
                            :if-exists :supersede)
      (format stream "# ~a~%~%" name)
      (format stream "## Description~%~%")
      (format stream "Your project description here.~%~%")
      (format stream "## Installation~%~%")
      (format stream "```lisp~%")
      (format stream "(ql:quickload :~a)~%" name)
      (format stream "```~%~%")
      (format stream "## Usage~%~%")
      (format stream "```lisp~%")
      (format stream "(~a:main)~%" name)
      (format stream "```~%~%")
      (format stream "## License~%~%")
      (format stream "~a~%" license))

    (format t "~&Scaffolded project: ~a~%" project-path)
    project-path))

;;; ============================================================================
;;; ASDF System Management
;;; ============================================================================

(defun systems ()
  "List all registered ASDF systems."
  (sort (asdf:registered-systems) #'string<))

(defun system-info (system-name)
  "Display information about an ASDF system."
  (let ((system (asdf:find-system system-name nil)))
    (if system
        (progn
          (format t "~&System: ~a~%" (asdf:component-name system))
          (format t "Version: ~a~%" (asdf:component-version system))
          (format t "Description: ~a~%"
                  (asdf:system-description system))
          (format t "Author: ~a~%"
                  (asdf:system-author system))
          (format t "License: ~a~%"
                  (asdf:system-license system))
          (format t "Dependencies: ~{~a~^, ~}~%"
                  (mapcar #'asdf:component-name
                          (asdf:component-sideway-dependencies system)))
          (format t "Source: ~a~%"
                  (asdf:system-source-directory system)))
        (format t "~&System not found: ~a~%" system-name))
    (values)))

(defun load-system (system-name)
  "Load an ASDF system."
  (handler-case
      (progn
        (asdf:load-system system-name)
        (format t "~&Loaded system: ~a~%" system-name))
    (error (e)
      (format t "~&Error loading system ~a: ~a~%" system-name e)))
  (values))

(defun test-system (system-name)
  "Run tests for an ASDF system."
  (handler-case
      (progn
        (asdf:test-system system-name)
        (format t "~&Tests completed for: ~a~%" system-name))
    (error (e)
      (format t "~&Error testing system ~a: ~a~%" system-name e)))
  (values))

;;; ============================================================================
;;; Local Projects Management
;;; ============================================================================

(defun local-projects ()
  "List all local Quicklisp projects."
  (let ((local-projects-dir (merge-pathnames
                             "quicklisp/local-projects/"
                             (user-homedir-pathname))))
    (when (probe-file local-projects-dir)
      (let ((projects (remove-if-not
                       #'uiop:directory-pathname-p
                       (uiop:subdirectories local-projects-dir))))
        (format t "~&Local projects (~d):~%" (length projects))
        (dolist (project projects)
          (format t "  ~a~%"
                  (car (last (pathname-directory project)))))
        projects))))

(defun project-path (project-name)
  "Get the path to a local project."
  (merge-pathnames
   (str "quicklisp/local-projects/" project-name "/")
   (user-homedir-pathname)))

(defun open-project (project-name)
  "Change to project directory and load it."
  (let ((path (project-path project-name)))
    (if (probe-file path)
        (progn
          (cd path)
          (format t "~&Changed to: ~a~%" path)
          (handler-case
              (progn
                (ql:quickload (intern (string-upcase project-name) :keyword))
                (format t "~&Loaded project: ~a~%" project-name))
            (error (e)
              (format t "~&Could not load project: ~a~%" e))))
        (format t "~&Project not found: ~a~%" project-name)))
  (values))

;;; ============================================================================
;;; Quicklisp Updates
;;; ============================================================================

(defun update-quicklisp ()
  "Update Quicklisp to the latest version."
  (handler-case
      (progn
        (ql:update-client)
        (ql:update-all-dists)
        (format t "~&Quicklisp updated successfully.~%"))
    (error (e)
      (format t "~&Error updating Quicklisp: ~a~%" e)))
  (values))

(defun ql-dist-info ()
  "Show information about installed Quicklisp distributions."
  (format t "~&Quicklisp distributions:~%")
  (dolist (dist (ql-dist:all-dists))
    (format t "  ~a~%" (ql-dist:name dist))
    (format t "    Version: ~a~%" (ql-dist:version dist))
    (format t "    Systems: ~d~%" (length (ql-dist:provided-systems dist))))
  (values))

;;; ============================================================================
;;; Workspace Management
;;; ============================================================================

(defvar *workspaces* (make-hash-table :test 'equal)
  "Hash table of saved workspaces.")

(defun save-workspace (name)
  "Save current workspace (directory and loaded systems)."
  (setf (gethash name *workspaces*)
        (list :directory (pwd)
              :systems (remove-duplicates
                        (mapcar #'asdf:component-name
                                (asdf:already-loaded-systems))
                        :test #'string=)))
  (format t "~&Saved workspace: ~a~%" name)
  (values))

(defun load-workspace (name)
  "Load a saved workspace."
  (let ((workspace (gethash name *workspaces*)))
    (if workspace
        (progn
          (cd (getf workspace :directory))
          (format t "~&Restored directory: ~a~%" (pwd))
          (dolist (system (getf workspace :systems))
            (handler-case
                (asdf:load-system system :verbose nil)
              (error (e)
                (format t "~&Warning: Could not load system ~a: ~a~%"
                        system e))))
          (format t "~&Loaded workspace: ~a~%" name))
        (format t "~&Workspace not found: ~a~%" name)))
  (values))

(defun list-workspaces ()
  "List all saved workspaces."
  (format t "~&Saved workspaces:~%")
  (maphash (lambda (name workspace)
             (format t "  ~a: ~a~%"
                     name
                     (getf workspace :directory)))
           *workspaces*)
  (values))

(format t "~&; Project management layer loaded.~%")
