;;;; dev.lisp - Development Layer
;;;; Debugging, profiling, inspection, and development utilities

(in-package #:cl-user)

;;; ============================================================================
;;; Inspection Utilities
;;; ============================================================================

(defun inspect-object (object)
  "Enhanced inspection of objects."
  (format t "~&Object: ~s~%" object)
  (format t "Type: ~a~%" (type-of object))
  (format t "Class: ~a~%" (class-of object))
  (when (typep object 'standard-object)
    (format t "~&Slots:~%")
    (loop for slot in (sb-mfc:class-slots (class-of object))
          for slot-name = (sb-mfc:slot-definition-name slot)
          do (format t "  ~a: ~a~%"
                     slot-name
                     (if (slot-boundp object slot-name)
                         (slot-value object slot-name)
                         "#<unbound>"))))
  (values))

(defun what-is (symbol)
  "Tell everything about a symbol."
  (format t "~&Symbol: ~s~%" symbol)
  (format t "Package: ~a~%"
          (if (symbol-package symbol)
              (package-name (symbol-package symbol))
              "no package"))

  (when (fboundp symbol)
    (format t "~&Function: YES~%")
    (format t "  Type: ~a~%"
            (cond ((macro-function symbol) "MACRO")
                  ((special-operator-p symbol) "SPECIAL-OPERATOR")
                  (t "FUNCTION")))
    (when (documentation symbol 'function)
      (format t "  Doc: ~a~%" (documentation symbol 'function))))

  (when (boundp symbol)
    (format t "~&Variable: YES~%")
    (format t "  Value: ~s~%" (symbol-value symbol))
    (when (documentation symbol 'variable)
      (format t "  Doc: ~a~%" (documentation symbol 'variable))))

  (when (find-class symbol nil)
    (format t "~&Class: YES~%")
    (when (documentation symbol 'type)
      (format t "  Doc: ~a~%" (documentation symbol 'type))))

  (values))

(defun who-calls (function)
  "Find who calls a given function."
  #+sbcl
  (let ((callers (sb-introspect:find-function-callers function)))
    (if callers
        (progn
          (format t "~&Functions calling ~a:~%" function)
          (dolist (caller callers)
            (format t "  ~a~%" caller)))
        (format t "~&No callers found for ~a~%" function)))
  #-sbcl
  (format t "~&WHO-CALLS not available on this implementation~%")
  (values))

(defun who-references (symbol)
  "Find who references a given symbol."
  #+sbcl
  (let ((references (sb-introspect:find-function-callees
                     (fdefinition symbol))))
    (if references
        (progn
          (format t "~&~a references:~%" symbol)
          (dolist (ref references)
            (format t "  ~a~%" ref)))
        (format t "~&No references found for ~a~%" symbol)))
  #-sbcl
  (format t "~&WHO-REFERENCES not available on this implementation~%")
  (values))

;;; ============================================================================
;;; Source Code Navigation
;;; ============================================================================

(defun source (symbol)
  "Find source location of a symbol."
  #+sbcl
  (let ((location (sb-introspect:find-definition-source-by-name
                   symbol :function)))
    (if location
        (format t "~&Source: ~a~%" (sb-introspect:definition-source-pathname location))
        (format t "~&No source location found for ~a~%" symbol)))
  #-sbcl
  (format t "~&SOURCE not available on this implementation~%")
  (values))

(defun disassemble-form (form)
  "Disassemble a form."
  (disassemble (compile nil `(lambda () ,form))))

;;; ============================================================================
;;; Profiling
;;; ============================================================================

(defvar *profiled-functions* nil
  "List of currently profiled functions.")

(defun profile-function (function-name)
  "Profile a specific function."
  #+sbcl
  (progn
    (sb-profile:profile function-name)
    (push function-name *profiled-functions*)
    (format t "~&Profiling ~a~%" function-name))
  #-sbcl
  (format t "~&Profiling not available on this implementation~%"))

(defun unprofile-function (function-name)
  "Stop profiling a specific function."
  #+sbcl
  (progn
    (sb-profile:unprofile function-name)
    (setf *profiled-functions* (remove function-name *profiled-functions*))
    (format t "~&Stopped profiling ~a~%" function-name))
  #-sbcl
  (format t "~&Profiling not available on this implementation~%"))

(defun unprofile-all ()
  "Stop profiling all functions."
  #+sbcl
  (progn
    (sb-profile:unprofile)
    (setf *profiled-functions* nil)
    (format t "~&Stopped all profiling~%"))
  #-sbcl
  (format t "~&Profiling not available on this implementation~%"))

(defun profile-report ()
  "Show profiling report."
  #+sbcl
  (sb-profile:report)
  #-sbcl
  (format t "~&Profiling not available on this implementation~%"))

(defun profile-reset ()
  "Reset profiling data."
  #+sbcl
  (sb-profile:reset)
  #-sbcl
  (format t "~&Profiling not available on this implementation~%"))

(defmacro with-profiling (functions &body body)
  "Profile specific functions during body execution."
  `(progn
     (dolist (fn ',functions)
       (profile-function fn))
     (unwind-protect
          (progn ,@body)
       (profile-report)
       (dolist (fn ',functions)
         (unprofile-function fn)))))

;;; ============================================================================
;;; Memory and GC
;;; ============================================================================

(defun memory-info ()
  "Display memory information."
  #+sbcl
  (let ((dynamic-usage (sb-kernel:dynamic-usage))
        (gc-count (sb-ext:gc-count)))
    (format t "~&Memory Information:~%")
    (format t "  Dynamic usage: ~:d bytes (~,2f MB)~%"
            dynamic-usage
            (/ dynamic-usage 1024.0 1024.0))
    (format t "  GC count: ~d~%" gc-count))
  #-sbcl
  (format t "~&Memory info not available on this implementation~%")
  (values))

(defun gc ()
  "Force garbage collection and show stats."
  (let ((before #+sbcl (sb-kernel:dynamic-usage)
                #-sbcl 0))
    #+sbcl (sb-ext:gc :full t)
    #-sbcl (error "GC not implemented")
    (let ((after #+sbcl (sb-kernel:dynamic-usage)
                 #-sbcl 0))
      (format t "~&GC completed.~%")
      (format t "  Before: ~:d bytes (~,2f MB)~%"
              before (/ before 1024.0 1024.0))
      (format t "  After:  ~:d bytes (~,2f MB)~%"
              after (/ after 1024.0 1024.0))
      (format t "  Freed:  ~:d bytes (~,2f MB)~%"
              (- before after) (/ (- before after) 1024.0 1024.0))))
  (values))

;;; ============================================================================
;;; Debugging Utilities
;;; ============================================================================

(defvar *debug-mode* nil
  "Whether debug mode is enabled.")

(defun debug-on ()
  "Enable debug mode."
  (setf *debug-mode* t)
  (setf *print-level* nil)
  (setf *print-length* nil)
  #+sbcl (sb-ext:restrict-compiler-policy 'debug 3)
  (format t "~&Debug mode enabled.~%")
  (values))

(defun debug-off ()
  "Disable debug mode."
  (setf *debug-mode* nil)
  (setf *print-level* 10)
  (setf *print-length* 100)
  (format t "~&Debug mode disabled.~%")
  (values))

(defmacro dbg (tag form)
  "Debug print a form with a tag."
  `(let ((result ,form))
     (format t "~&[~a] ~s => ~s~%" ,tag ',form result)
     result))

(defmacro trace-vars (&rest vars)
  "Trace changes to variables."
  `(progn
     ,@(loop for var in vars
             collect `(defparameter ,var
                        (let ((old-value (if (boundp ',var)
                                             (symbol-value ',var)
                                             :unbound)))
                          (format t "~&[TRACE] ~a changed from ~s to ~s~%"
                                  ',var old-value ,var)
                          ,var)))))

;;; ============================================================================
;;; Testing Helpers
;;; ============================================================================

(defmacro assert-equal (expected actual &optional message)
  "Simple assertion for testing."
  `(if (equal ,expected ,actual)
       (format t "~&✓ PASS~@[: ~a~]~%" ,message)
       (format t "~&✗ FAIL~@[: ~a~]~%  Expected: ~s~%  Got:      ~s~%"
               ,message ,expected ,actual)))

(defmacro assert-true (form &optional message)
  "Assert that form evaluates to true."
  `(if ,form
       (format t "~&✓ PASS~@[: ~a~]~%" ,message)
       (format t "~&✗ FAIL~@[: ~a~]~%  Expression: ~s~%  Result: NIL~%"
               ,message ',form)))

(defmacro test-group (name &body tests)
  "Group related tests."
  `(progn
     (format t "~&~%Testing: ~a~%" ,name)
     (format t "~v@{~a~:*~}" 60 "=")
     (format t "~%")
     ,@tests
     (format t "~v@{~a~:*~}" 60 "=")
     (format t "~%")))

;;; ============================================================================
;;; Code Quality
;;; ============================================================================

(defun check-style (package)
  "Basic style checker for package."
  (let ((long-names 0)
        (undocumented-fns 0))
    (do-symbols (sym package)
      (when (eq (symbol-package sym) (find-package package))
        ;; Check name length
        (when (> (length (symbol-name sym)) 30)
          (incf long-names)
          (format t "~&Warning: Long name: ~a~%" sym))
        ;; Check documentation
        (when (and (fboundp sym)
                   (not (documentation sym 'function)))
          (incf undocumented-fns)
          (format t "~&Warning: Undocumented function: ~a~%" sym))))
    (format t "~&~%Style Check Summary:~%")
    (format t "  Long names: ~d~%" long-names)
    (format t "  Undocumented functions: ~d~%" undocumented-fns))
  (values))

;;; ============================================================================
;;; REPL Enhancements
;;; ============================================================================

(defun reload ()
  "Reload all modified files in the current system."
  (when (asdf:find-system :asdf nil)
    (asdf:load-system (asdf:find-system :asdf))
    (format t "~&System reloaded.~%"))
  (values))

(defun clean ()
  "Clean compiled files."
  #+sbcl
  (let ((fasl-files (directory "**/*.fasl")))
    (dolist (file fasl-files)
      (delete-file file)
      (format t "~&Deleted: ~a~%" file))
    (format t "~&Cleaned ~d FASL files.~%" (length fasl-files)))
  #-sbcl
  (format t "~&Clean not implemented for this Lisp~%")
  (values))

(format t "~&; Development layer loaded.~%")
