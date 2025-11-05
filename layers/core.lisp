;;;; core.lisp - Core Layer
;;;; Essential utilities, aliases, and REPL enhancements

(in-package #:cl-user)

;;; ============================================================================
;;; Core Utilities
;;; ============================================================================

(defun str (&rest elements)
  "Concatenate all elements into a string."
  (format nil "~{~a~}"
          (mapcar (lambda (x)
                    (cond ((numberp x) (write-to-string x))
                          ((symbolp x) (symbol-name x))
                          (t x)))
                  elements)))

(defun join (separator list)
  "Join a list of items with a separator string."
  (format nil (concatenate 'string "~{~a~^" (string separator) "~}") list))

(defun split (string separator)
  "Split a string by separator."
  (loop for start = 0 then (1+ end)
        for end = (position separator string :start start)
        collect (subseq string start end)
        while end))

(defun assoc-str (key alist)
  "Access alists with string keys."
  (assoc key alist :test 'equal))

(defun plist-keys (plist)
  "Get all keys from a plist."
  (loop for key in plist by #'cddr collect key))

(defun plist-values (plist)
  "Get all values from a plist."
  (loop for (key val) on plist by #'cddr collect val))

(defun hash-to-alist (hash-table)
  "Convert a hash table to an alist."
  (loop for key being the hash-keys of hash-table
        using (hash-value value)
        collect (cons key value)))

(defun alist-to-hash (alist &key (test 'eql))
  "Convert an alist to a hash table."
  (let ((hash (make-hash-table :test test)))
    (loop for (key . value) in alist
          do (setf (gethash key hash) value))
    hash))

;;; ============================================================================
;;; File System Utilities
;;; ============================================================================

(defun pwd ()
  "Get current working directory."
  #+sbcl (sb-posix:getcwd)
  #-sbcl (truename "."))

(defun cd (path)
  "Change directory."
  #+sbcl (sb-posix:chdir (namestring path))
  #-sbcl (error "CD not implemented for this Lisp"))

(defun ls (&optional (path "."))
  "List directory contents."
  (directory (merge-pathnames
              (make-pathname :name :wild :type :wild)
              path)))

(defun mkdir (path)
  "Create a directory."
  (ensure-directories-exist path))

(defun file-exists-p (path)
  "Check if a file exists."
  (probe-file path))

(defun read-file-string (path)
  "Read entire file as a string."
  (with-open-file (stream path :direction :input)
    (let ((contents (make-string (file-length stream))))
      (read-sequence contents stream)
      contents)))

(defun write-file-string (path string)
  "Write string to a file."
  (with-open-file (stream path
                          :direction :output
                          :if-exists :supersede
                          :if-does-not-exist :create)
    (write-sequence string stream)))

;;; ============================================================================
;;; System Utilities
;;; ============================================================================

(defun getenv (var)
  "Get environment variable."
  #+sbcl (sb-unix::posix-getenv var)
  #-sbcl (error "GETENV not implemented for this Lisp"))

(defun setenv (var value)
  "Set environment variable."
  #+sbcl (sb-posix:setenv var value 1)
  #-sbcl (error "SETENV not implemented for this Lisp"))

(defun shell (command)
  "Execute a shell command and return output."
  #+sbcl
  (let ((stream (sb-ext:process-output
                 (sb-ext:run-program "/bin/sh"
                                     (list "-c" command)
                                     :output :stream
                                     :wait nil))))
    (let ((output (make-string-output-stream)))
      (loop for line = (read-line stream nil nil)
            while line
            do (write-line line output))
      (get-output-stream-string output)))
  #-sbcl (error "SHELL not implemented for this Lisp"))

;;; ============================================================================
;;; Timing and Performance
;;; ============================================================================

(defmacro benchmark ((&key (times 1)) &body body)
  "Benchmark code execution."
  (let ((start (gensym "START"))
        (end (gensym "END"))
        (i (gensym "I")))
    `(let ((,start (get-internal-real-time)))
       (dotimes (,i ,times)
         ,@body)
       (let ((,end (get-internal-real-time)))
         (format t "~&Execution time: ~,6f seconds (~d iteration~:p)~%"
                 (/ (- ,end ,start)
                    internal-time-units-per-second
                    ,times)
                 ,times)))))

(defmacro with-timing (&body body)
  "Execute body and print execution time."
  `(benchmark (:times 1) ,@body))

;;; ============================================================================
;;; REPL Enhancements
;;; ============================================================================

;; Better output for lists and structures
(defun pp (object)
  "Pretty print an object."
  (pprint object)
  (values))

(defun pph (hash-table)
  "Pretty print a hash table."
  (format t "~&Hash Table (~d entries):~%" (hash-table-count hash-table))
  (maphash (lambda (key value)
             (format t "  ~s => ~s~%" key value))
           hash-table)
  (values))

;; History-like functionality
(defvar *repl-history* nil
  "History of evaluated expressions.")

(defvar *max-history-size* 100
  "Maximum number of history entries to keep.")

(defun add-to-history (expr)
  "Add expression to history."
  (push expr *repl-history*)
  (when (> (length *repl-history*) *max-history-size*)
    (setf *repl-history* (subseq *repl-history* 0 *max-history-size*))))

(defun history (&optional (n 20))
  "Show recent REPL history."
  (format t "~&Recent history (~d entries):~%" (min n (length *repl-history*)))
  (loop for expr in (subseq *repl-history* 0 (min n (length *repl-history*)))
        for i from 1
        do (format t "~&~3d: ~s~%" i expr))
  (values))

;;; ============================================================================
;;; Quick Access Functions
;;; ============================================================================

(defun packages ()
  "List all packages."
  (sort (mapcar #'package-name (list-all-packages)) #'string<))

(defun exports (package)
  "List all exported symbols from a package."
  (let ((symbols nil))
    (do-external-symbols (s (find-package package))
      (push s symbols))
    (sort symbols #'string< :key #'symbol-name)))

(defun package-symbols (package)
  "List all symbols in a package."
  (let ((symbols nil))
    (do-symbols (s (find-package package))
      (when (eq (symbol-package s) (find-package package))
        (push s symbols)))
    (sort symbols #'string< :key #'symbol-name)))

(defun functions (package)
  "List all function symbols in a package."
  (remove-if-not #'fboundp (package-symbols package)))

(defun macros (package)
  "List all macro symbols in a package."
  (remove-if-not #'macro-function (package-symbols package)))

(defun variables (package)
  "List all variable symbols in a package."
  (remove-if-not #'boundp (package-symbols package)))

;;; ============================================================================
;;; Aliases for Common Operations
;;; ============================================================================

(defmacro alias (to fn)
  "Create an alias for a function."
  `(setf (fdefinition ',to) #',fn))

;; Common shortcuts
(alias quit sb-ext:quit)
(alias exit sb-ext:quit)
(alias ed ed)

;; List operations
(alias first cl:first)
(alias rest cl:rest)
(alias last cl:last)

;; Type checking shortcuts
(alias type-of cl:type-of)
(alias class-of cl:class-of)

;;; ============================================================================
;;; Better Error Handling
;;; ============================================================================

(defun safe-load (file)
  "Load a file with error handling."
  (handler-case
      (progn
        (load file)
        (format t "~&; Successfully loaded: ~a~%" file)
        t)
    (error (e)
      (format t "~&; Error loading ~a: ~a~%" file e)
      nil)))

(defun safe-require (system)
  "Require a system with error handling."
  (handler-case
      (progn
        (require system)
        (format t "~&; Successfully required: ~a~%" system)
        t)
    (error (e)
      (format t "~&; Error requiring ~a: ~a~%" system e)
      nil)))

;;; ============================================================================
;;; Quicklisp Helpers
;;; ============================================================================

(defun ql (system)
  "Quick shortcut for quickload."
  (ql:quickload system :silent t))

(defun qls (&optional search-term)
  "Search for systems in Quicklisp."
  (if search-term
      (ql:system-apropos search-term)
      (format t "Usage: (qls \"search-term\")~%")))

;;; ============================================================================
;;; Initialization
;;; ============================================================================

;; Set better defaults
(setf *print-case* :downcase)  ; Print symbols in lowercase
(setf *print-length* 100)      ; Limit list printing length
(setf *print-level* 10)        ; Limit nesting depth

;; Muffle warnings during init
(declaim (sb-ext:muffle-conditions cl:warning))

(format t "~&; Core layer loaded.~%")
