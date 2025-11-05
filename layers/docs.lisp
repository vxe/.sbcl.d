;;;; docs.lisp - Documentation Layer
;;;; Help system, documentation search, and learning utilities

(in-package #:cl-user)

;;; ============================================================================
;;; Help System
;;; ============================================================================

(defun help (&optional topic)
  "Display help information."
  (if topic
      (help-topic topic)
      (help-overview)))

(defun help-overview ()
  "Display overview of available commands."
  (format t "~&~%")
  (format t "╔════════════════════════════════════════════════════════════════╗~%")
  (format t "║           SBCL Configuration System - Help                    ║~%")
  (format t "╚════════════════════════════════════════════════════════════════╝~%")
  (format t "~%")

  (format t "CORE UTILITIES:~%")
  (format t "  (help [topic])      - Show this help or help for specific topic~%")
  (format t "  (pwd)               - Print working directory~%")
  (format t "  (cd path)           - Change directory~%")
  (format t "  (ls [path])         - List directory contents~%")
  (format t "  (shell cmd)         - Execute shell command~%")
  (format t "  (pp object)         - Pretty print object~%")
  (format t "  (pph hash)          - Pretty print hash table~%")
  (format t "  (history [n])       - Show REPL history~%")
  (format t "  (quit) (exit)       - Exit SBCL~%")
  (format t "~%")

  (format t "DOCUMENTATION:~%")
  (format t "  (doc symbol)        - Show documentation for symbol~%")
  (format t "  (search-doc term)   - Search documentation~%")
  (format t "  (examples symbol)   - Show examples for symbol~%")
  (format t "  (apropos-full term) - Enhanced apropos search~%")
  (format t "  (what-is symbol)    - Complete information about symbol~%")
  (format t "~%")

  (format t "PROJECT MANAGEMENT:~%")
  (format t "  (new-project name)  - Create new Quicklisp project~%")
  (format t "  (scaffold-project name) - Create scaffolded project~%")
  (format t "  (local-projects)    - List local projects~%")
  (format t "  (open-project name) - Open and load project~%")
  (format t "  (ql system)         - Quick load system~%")
  (format t "  (qls term)          - Search Quicklisp~%")
  (format t "~%")

  (format t "DEVELOPMENT:~%")
  (format t "  (inspect-object obj) - Inspect object details~%")
  (format t "  (source symbol)     - Find source location~%")
  (format t "  (who-calls fn)      - Find function callers~%")
  (format t "  (profile-function fn) - Profile a function~%")
  (format t "  (profile-report)    - Show profiling report~%")
  (format t "  (memory-info)       - Display memory info~%")
  (format t "  (gc)                - Force garbage collection~%")
  (format t "  (debug-on/off)      - Toggle debug mode~%")
  (format t "~%")

  (format t "SYSTEM:~%")
  (format t "  (reload-config)     - Reload SBCL configuration~%")
  (format t "  (load-layer name)   - Load a specific layer~%")
  (format t "  (packages)          - List all packages~%")
  (format t "  (systems)           - List all ASDF systems~%")
  (format t "~%")

  (format t "For more details: (help :topic)~%")
  (format t "Available topics: :layers :config :quicklisp :profiling~%")
  (format t "~%")
  (values))

(defun help-topic (topic)
  "Display help for a specific topic."
  (case topic
    (:layers
     (format t "~&~%LAYERS SYSTEM~%")
     (format t "═══════════════~%~%")
     (format t "The configuration system is organized into layers:~%~%")
     (format t "  :core    - Essential utilities and REPL enhancements~%")
     (format t "  :dev     - Development tools (debugging, profiling)~%")
     (format t "  :project - Project management and Quicklisp~%")
     (format t "  :docs    - Documentation and help system~%~%")
     (format t "Enable/disable layers in user-config.lisp:~%")
     (format t "  (in-package #:sbcl-config)~%")
     (format t "  (setf *enabled-layers* '(:core :dev :project :docs))~%~%")
     (format t "Load a layer dynamically:~%")
     (format t "  (sbcl-config:load-layer :layer-name)~%~%"))

    (:config
     (format t "~&~%CONFIGURATION~%")
     (format t "═════════════~%~%")
     (format t "Configuration files:~%~%")
     (format t "  ~/.sbcl.d/.sbclrc        - Main configuration file~%")
     (format t "  ~/.sbcl.d/user-config.lisp - User customizations~%")
     (format t "  ~/.sbcl.d/layers/        - Layer definitions~%~%")
     (format t "Reload configuration:~%")
     (format t "  (sbcl-config:reload-config)~%~%")
     (format t "Create user-config.lisp to customize:~%")
     (format t "  - Enabled layers~%")
     (format t "  - Personal functions~%")
     (format t "  - Project-specific settings~%~%"))

    (:quicklisp
     (format t "~&~%QUICKLISP INTEGRATION~%")
     (format t "═════════════════════~%~%")
     (format t "Quick load systems:~%")
     (format t "  (ql :system-name)~%~%")
     (format t "Search for systems:~%")
     (format t "  (qls \"search-term\")~%~%")
     (format t "Create new project:~%")
     (format t "  (new-project \"my-project\" :dep1 :dep2)~%~%")
     (format t "Update Quicklisp:~%")
     (format t "  (update-quicklisp)~%~%")
     (format t "List local projects:~%")
     (format t "  (local-projects)~%~%"))

    (:profiling
     (format t "~&~%PROFILING~%")
     (format t "═════════~%~%")
     (format t "Profile a function:~%")
     (format t "  (profile-function 'my-function)~%~%")
     (format t "Stop profiling:~%")
     (format t "  (unprofile-function 'my-function)~%")
     (format t "  (unprofile-all)~%~%")
     (format t "View results:~%")
     (format t "  (profile-report)~%~%")
     (format t "Reset profiling data:~%")
     (format t "  (profile-reset)~%~%")
     (format t "Profile code block:~%")
     (format t "  (with-profiling (fn1 fn2)~%")
     (format t "    (your-code-here))~%~%"))

    (otherwise
     (format t "~&Unknown topic: ~a~%" topic)
     (format t "Available topics: :layers :config :quicklisp :profiling~%")))
  (values))

;;; ============================================================================
;;; Documentation Search
;;; ============================================================================

(defun doc (symbol)
  "Show all documentation for a symbol."
  (format t "~&Symbol: ~s~%~%" symbol)

  (when (documentation symbol 'function)
    (format t "Function documentation:~%")
    (format t "  ~a~%~%" (documentation symbol 'function)))

  (when (documentation symbol 'variable)
    (format t "Variable documentation:~%")
    (format t "  ~a~%~%" (documentation symbol 'variable)))

  (when (documentation symbol 'type)
    (format t "Type documentation:~%")
    (format t "  ~a~%~%" (documentation symbol 'type)))

  (when (documentation symbol 'setf)
    (format t "Setf documentation:~%")
    (format t "  ~a~%~%" (documentation symbol 'setf)))

  (unless (or (documentation symbol 'function)
              (documentation symbol 'variable)
              (documentation symbol 'type)
              (documentation symbol 'setf))
    (format t "No documentation found.~%"))

  (values))

(defun search-doc (search-term)
  "Search for symbols with matching documentation."
  (let ((results nil))
    (do-all-symbols (sym)
      (when (and (documentation sym 'function)
                 (search search-term
                         (documentation sym 'function)
                         :test #'char-equal))
        (push sym results)))
    (if results
        (progn
          (format t "~&Found ~d symbols with matching documentation:~%"
                  (length results))
          (dolist (sym (sort results #'string< :key #'symbol-name))
            (format t "~&  ~a~%" sym)
            (let ((doc (documentation sym 'function)))
              (when doc
                (format t "    ~a~%"
                        (subseq doc 0 (min 60 (length doc))))))))
        (format t "~&No documentation found matching: ~a~%" search-term)))
  (values))

(defun apropos-full (string-designator)
  "Enhanced apropos with categorization."
  (let ((functions nil)
        (macros nil)
        (variables nil)
        (classes nil))

    (do-all-symbols (sym)
      (when (search string-designator (symbol-name sym) :test #'char-equal)
        (cond ((macro-function sym) (push sym macros))
              ((fboundp sym) (push sym functions))
              ((boundp sym) (push sym variables))
              ((find-class sym nil) (push sym classes)))))

    (format t "~&Search results for: ~a~%~%" string-designator)

    (when functions
      (format t "Functions (~d):~%" (length functions))
      (dolist (sym (sort functions #'string< :key #'symbol-name))
        (format t "  ~a~@[ - ~a~]~%"
                sym
                (let ((doc (documentation sym 'function)))
                  (when doc
                    (subseq doc 0 (min 50 (length doc)))))))
      (format t "~%"))

    (when macros
      (format t "Macros (~d):~%" (length macros))
      (dolist (sym (sort macros #'string< :key #'symbol-name))
        (format t "  ~a~@[ - ~a~]~%"
                sym
                (let ((doc (documentation sym 'function)))
                  (when doc
                    (subseq doc 0 (min 50 (length doc)))))))
      (format t "~%"))

    (when variables
      (format t "Variables (~d):~%" (length variables))
      (dolist (sym (sort variables #'string< :key #'symbol-name))
        (format t "  ~a~@[ - ~a~]~%"
                sym
                (let ((doc (documentation sym 'variable)))
                  (when doc
                    (subseq doc 0 (min 50 (length doc)))))))
      (format t "~%"))

    (when classes
      (format t "Classes (~d):~%" (length classes))
      (dolist (sym (sort classes #'string< :key #'symbol-name))
        (format t "  ~a~@[ - ~a~]~%"
                sym
                (let ((doc (documentation sym 'type)))
                  (when doc
                    (subseq doc 0 (min 50 (length doc)))))))
      (format t "~%"))

    (unless (or functions macros variables classes)
      (format t "No matches found.~%")))
  (values))

;;; ============================================================================
;;; Learning Utilities
;;; ============================================================================

(defvar *examples* (make-hash-table :test 'eq)
  "Hash table of examples for symbols.")

(defun add-example (symbol example-string)
  "Add an example for a symbol."
  (push example-string (gethash symbol *examples*))
  (format t "~&Added example for ~a~%" symbol)
  (values))

(defun examples (symbol)
  "Show examples for a symbol."
  (let ((symbol-examples (gethash symbol *examples*)))
    (if symbol-examples
        (progn
          (format t "~&Examples for ~a:~%~%" symbol)
          (dolist (example (reverse symbol-examples))
            (format t "~a~%~%" example)))
        (format t "~&No examples found for ~a~%" symbol)))
  (values))

;;; ============================================================================
;;; Common Lisp Quick Reference
;;; ============================================================================

(defun quickref (&optional category)
  "Quick reference for Common Lisp."
  (if category
      (quickref-category category)
      (quickref-overview)))

(defun quickref-overview ()
  "Show quickref categories."
  (format t "~&~%QUICK REFERENCE CATEGORIES:~%")
  (format t "  (quickref :lists)      - List operations~%")
  (format t "  (quickref :strings)    - String operations~%")
  (format t "  (quickref :sequences)  - Sequence operations~%")
  (format t "  (quickref :hash)       - Hash table operations~%")
  (format t "  (quickref :files)      - File I/O~%")
  (format t "  (quickref :control)    - Control flow~%")
  (format t "  (quickref :loops)      - Loop constructs~%")
  (values))

(defun quickref-category (category)
  "Show quickref for a specific category."
  (case category
    (:lists
     (format t "~&~%LIST OPERATIONS:~%")
     (format t "  (car list)          - First element~%")
     (format t "  (cdr list)          - Rest of list~%")
     (format t "  (cons item list)    - Add to front~%")
     (format t "  (append l1 l2)      - Concatenate lists~%")
     (format t "  (reverse list)      - Reverse list~%")
     (format t "  (length list)       - List length~%")
     (format t "  (nth n list)        - Get nth element~%")
     (format t "  (member item list)  - Check membership~%")
     (format t "  (remove item list)  - Remove elements~%")
     (format t "  (mapcar fn list)    - Map function~%"))

    (:strings
     (format t "~&~%STRING OPERATIONS:~%")
     (format t "  (string= s1 s2)     - String equality~%")
     (format t "  (string< s1 s2)     - String less than~%")
     (format t "  (concatenate 'string s1 s2) - Concatenate~%")
     (format t "  (subseq str start [end]) - Substring~%")
     (format t "  (length str)        - String length~%")
     (format t "  (char str n)        - Get character~%")
     (format t "  (string-upcase str) - Uppercase~%")
     (format t "  (string-downcase str) - Lowercase~%"))

    (:hash
     (format t "~&~%HASH TABLE OPERATIONS:~%")
     (format t "  (make-hash-table)   - Create hash table~%")
     (format t "  (gethash key ht)    - Get value~%")
     (format t "  (setf (gethash key ht) val) - Set value~%")
     (format t "  (remhash key ht)    - Remove entry~%")
     (format t "  (clrhash ht)        - Clear hash table~%")
     (format t "  (hash-table-count ht) - Number of entries~%")
     (format t "  (maphash fn ht)     - Iterate over hash~%"))

    (otherwise
     (format t "~&Unknown category: ~a~%" category)
     (quickref-overview)))
  (values))

;;; ============================================================================
;;; Initialization
;;; ============================================================================

;; Add some example examples
(add-example 'mapcar "(mapcar #'1+ '(1 2 3)) => (2 3 4)")
(add-example 'reduce "(reduce #'+ '(1 2 3 4)) => 10")
(add-example 'remove-if "(remove-if #'oddp '(1 2 3 4)) => (2 4)")

(format t "~&; Documentation layer loaded.~%")
