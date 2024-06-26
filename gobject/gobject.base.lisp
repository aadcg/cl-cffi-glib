;;; ----------------------------------------------------------------------------
;;; gobject.base.lisp
;;;
;;; The documentation of this file is taken from the GObject Reference Manual
;;; Version 2.76 and modified to document the Lisp binding to the GObject
;;; library. See <http://www.gtk.org>. The API documentation of the Lisp
;;; binding is available from <http://www.crategus.com/books/cl-cffi-gtk4/>.
;;;
;;; Copyright (C) 2011 - 2024 Dieter Kaiser
;;;
;;; Permission is hereby granted, free of charge, to any person obtaining a
;;; copy of this software and associated documentation files (the "Software"),
;;; to deal in the Software without restriction, including without limitation
;;; the rights to use, copy, modify, merge, publish, distribute, sublicense,
;;; and/or sell copies of the Software, and to permit persons to whom the
;;; Software is furnished to do so, subject to the following conditions:
;;;
;;; The above copyright notice and this permission notice shall be included in
;;; all copies or substantial portions of the Software.
;;;
;;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
;;; THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
;;; FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
;;; DEALINGS IN THE SOFTWARE.
;;; ----------------------------------------------------------------------------
;;;
;;; GObject
;;;
;;;     The base object type
;;;
;;; Types and Values
;;;
;;;     GObject
;;;     GObjectClass
;;;     GObjectConstructParam                              not exported
;;;     GParameter                                         not exported
;;;     GInitiallyUnowned
;;;     GInitiallyUnownedClass                             not implemented
;;;
;;; Functions
;;;
;;;     GObjectGetPropertyFunc
;;;     GObjectSetPropertyFunc
;;;     GObjectFinalizeFunc
;;;
;;;     G_TYPE_IS_OBJECT
;;;     G_OBJECT
;;;     G_IS_OBJECT
;;;     G_OBJECT_CLASS
;;;     G_IS_OBJECT_CLASS
;;;     G_OBJECT_GET_CLASS
;;;     G_OBJECT_TYPE
;;;     G_OBJECT_TYPE_NAME
;;;     G_OBJECT_CLASS_TYPE
;;;     G_OBJECT_CLASS_NAME
;;;
;;;     g_object_class_install_property                    not exported
;;;     g_object_class_install_properties                  not exported
;;;     g_object_class_find_property
;;;     g_object_class_list_properties
;;;     g_object_class_override_property                   not exported
;;;     g_object_interface_install_property                not exported
;;;     g_object_interface_find_property
;;;     g_object_interface_list_properties
;;;     g_object_new
;;;     g_object_new_with_properties                       not implemented
;;;     g_object_newv                                      not exported
;;;     g_object_ref                                       not exported
;;;     g_object_unref                                     not exported
;;;     g_object_ref_sink                                  not exported
;;;     g_set_object                                       not implemented
;;;     g_clear_object                                     not implemented
;;;     g_object_is_floating                               not exported
;;;     g_object_force_floating                            not exported
;;;
;;;     GWeakNotify
;;;     g_object_weak_ref
;;;     g_object_weak_unref                                not exported
;;;     g_object_add_weak_pointer                          not exported
;;;     g_object_remove_weak_pointer
;;;     g_set_weak_pointer
;;;     g_clear_weak_pointer
;;;
;;;     GToggleNotify
;;;     g_object_add_toggle_ref                            not exported
;;;     g_object_remove_toggle_ref                         not exported
;;;     g_object_connect
;;;     g_object_disconnect
;;;
;;;     g_object_set
;;;     g_object_setv
;;;     g_object_get
;;;     g_object_getv
;;;
;;;     g_object_notify
;;;     g_object_notify_by_pspec
;;;     g_object_freeze_notify
;;;     g_object_thaw_notify
;;;
;;;     g_object_get_data
;;;     g_object_set_data
;;;     g_object_set_data_full
;;;     g_object_steal_data
;;;     g_object_dup_data
;;;     g_object_replace_data
;;;     g_object_get_qdata
;;;     g_object_set_qdata
;;;     g_object_set_qdata_full
;;;     g_object_steal_qdata
;;;     g_object_dup_qdata
;;;     g_object_replace-qdata
;;;     g_object_set_property
;;;     g_object_get_property
;;;     g_object_new_valist
;;;     g_object_set_valist
;;;     g_object_get_valist
;;;     g_object_watch_closure
;;;     g_object_run_dispose
;;;
;;;     G_OBJECT_WARN_INVALID_PROPERTY_ID
;;;
;;;     g_weak_ref_init
;;;     g_weak_ref_clear
;;;     g_weak_ref_get
;;;     g_weak_ref_set
;;;     g_assert_finalize_object
;;;
;;; Signals
;;;
;;;     notify
;;;
;;; Object Hierarchy
;;;
;;;     GObject
;;;     ├── GBinding
;;;     ├── GInitiallyUnowned
;;;     ╰── GTypeModule
;;; ----------------------------------------------------------------------------

(in-package :gobject)

(defvar *foreign-gobjects-weak*
        (tg:make-weak-hash-table :test 'equal :weakness :value))
(defvar *foreign-gobjects-strong* (make-hash-table :test 'equal))
(defvar *current-creating-object* nil)
(defvar *current-object-from-pointer* nil)
(defvar *currently-making-object-p* nil)

(glib-init:at-finalize ()
  (clrhash *foreign-gobjects-weak*)
  (clrhash *foreign-gobjects-strong*)
  (setf *current-creating-object* nil
        *current-object-from-pointer* nil
        *currently-making-object-p* nil))

;; Access the hashtables with functions

(defun get-gobject-for-pointer-strong (ptr)
  (gethash (cffi:pointer-address ptr) *foreign-gobjects-strong*))

(defun (setf get-gobject-for-pointer-strong) (value ptr)
  (setf (gethash (cffi:pointer-address ptr) *foreign-gobjects-strong*) value))

(defun rem-gobject-for-pointer-strong (ptr)
  (remhash (cffi:pointer-address ptr) *foreign-gobjects-strong*))

(defun get-gobject-for-pointer-weak (ptr)
  (gethash (cffi:pointer-address ptr) *foreign-gobjects-weak*))

(defun (setf get-gobject-for-pointer-weak) (value ptr)
  (setf (gethash (cffi:pointer-address ptr) *foreign-gobjects-weak*) value))

(defun rem-gobject-for-pointer-weak (ptr)
  (remhash (cffi:pointer-address ptr) *foreign-gobjects-weak*))

(defun get-gobject-for-pointer (ptr)
  (or (gethash (cffi:pointer-address ptr) *foreign-gobjects-strong*)
      (gethash (cffi:pointer-address ptr) *foreign-gobjects-weak*)))

;;; ----------------------------------------------------------------------------
;;; GParameter                                              not exported
;;; ----------------------------------------------------------------------------

(cffi:defcstruct %parameter
  (name (:string :free-from-foreign nil :free-to-foreign nil))
  (value (:struct value)))

;;; ----------------------------------------------------------------------------
;;; GObject
;;;
;;; All the fields in the GObject structure are private to the GObject
;;; implementation and should never be accessed directly.
;;; ----------------------------------------------------------------------------

;; %object is not needed in the implementation.
;; It is defined to access the property ref-count for debugging the code.

(cffi:defcstruct %object
  (:type-instance (:pointer (:struct type-instance)))
  (:ref-count :uint)
  (:data :pointer))

;; Accessor for the slot ref-count of %object

(defun ref-count (pointer)
  (cffi:foreign-slot-value (if (cffi:pointerp pointer)
                               pointer
                               (object-pointer pointer))
                           '(:struct %object) :ref-count))

;;; ----------------------------------------------------------------------------

;; Define the base class object

(defclass object ()
  ((pointer
    :type (or null cffi:foreign-pointer)
    :initarg :pointer
    :accessor object-pointer
    :initform nil)
   (has-reference
    :type boolean
    :accessor object-has-reference
    :initform nil)
   (signal-handlers
    :type (array t *)
    :initform (make-array 0 :adjustable t :fill-pointer t)
    :reader object-signal-handlers)))

(export 'object)
(export 'object-pointer)
(export 'object-has-reference)
(export 'object-signal-handlers)

;; Add object to the global Hash table for registered types
(eval-when (:compile-toplevel :load-toplevel :execute)
  (setf (glib:symbol-for-gtype "GObject") 'object))

;;; ----------------------------------------------------------------------------

#+liber-documentation
(setf (documentation 'object 'type)
 "@version{2023-12-1}
  @begin{short}
    The @class{g:object} class is the fundamental type providing the common
    attributes and methods for all object types in GTK, Pango and other
    libraries.
  @end{short}
  The @class{g:object} class provides methods for object construction and
  destruction, property access methods, and signal support.
  @begin[Lisp Implementation]{dictionary}
    In the Lisp implementation three slots are added. The
    @slot[g:object]{pointer} slot holds the foreign pointer to the C instance
    of the object. The @slot[g:object]{signal-handlers} slot stores the Lisp
    functions which are connected to an instance with the @fun{g:signal-connect}
    function. The @slot[g:object]{has-reference} slot is initialized to the
    value @em{true} during creation of an object. See the slot access functions
    for examples.
  @end{dictionary}
  @begin[Signal Details]{dictionary}
    @subheading{The \"notify\" signal}
    @begin{pre}
lambda (object pspec)    :no-hooks
    @end{pre}
    The signal is emitted on an object when one of its properties has been
    changed. Note that getting this signal does not guarantee that the
    value of the property has actually changed, it may also be emitted when
    the setter for the property is called to reinstate the previous value.
    This signal is typically used to obtain change notification for a single
    property, by specifying the property name as a detail in the
    @fun{g:signal-connect} function call, like this:
    @begin{pre}
(g:signal-connect switch \"notify::active\"
   (lambda (widget pspec)
     (declare (ignore pspec))
     (if (gtk:switch-active widget)
         (setf (gtk:label-label label) \"The Switch is ON\")
         (setf (gtk:label-label label) \"The Switch is OFF\"))))
    @end{pre}
    It is important to note that you must use canonical parameter names as
    detail strings for the notify signal.
    @begin[code]{table}
      @entry[object]{The @class{g:object} instance which received the signal.}
      @entry[pspec]{The @symbol{g:param-spec} instance of the property which
        changed.}
    @end{table}
  @end{dictionary}
  @see-constructor{g:object-new}
  @see-slot{g:object-has-reference}
  @see-slot{g:object-pointer}
  @see-slot{g:object-signal-handlers}
  @see-symbol{g:param-spec}
  @see-function{g:signal-connect}")

;;; ----------------------------------------------------------------------------
;;; Property and Accessor details
;;; ----------------------------------------------------------------------------

;;; --- g:object-has-reference -------------------------------------------------

#+liber-documentation
(setf (documentation (liber:slot-documentation "has-reference" 'object) t)
 "Holds the value @em{true} when the instance is successfully registered.")

#+liber-documentation
(setf (liber:alias-for-function 'object-has-reference)
      "Accessor"
      (documentation 'object-has-reference 'function)
 "@version{2023-12-1}
  @syntax[]{(g:object-has-reference object) => has-reference}
  @argument[object]{a @class{g:object} instance}
  @argument[has-reference]{@em{true} when registering @arg{object}}
  @begin{short}
    Accessor of the @code{has-reference} slot of the @class{g:object} class.
  @end{short}
  The slot is set to @em{true} when registering an object during creation.
  @see-class{g:object}")

;;; --- g:object-pointer -------------------------------------------------------

#+liber-documentation
(setf (documentation (liber:slot-documentation "pointer" 'object) t)
 "Holds a foreign pointer to the C instance of a GObject.")

#+liber-documentation
(setf (liber:alias-for-function 'object-pointer)
      "Accessor"
      (documentation 'object-pointer 'function)
 "@version{2023-12-1}
  @syntax[]{(g:object-pointer object) => pointer}
  @argument[object]{a @class{g:object} instance}
  @argument[pointer]{a foreign pointer to the C instance of @arg{object}}
  @begin{short}
    Accessor of the @slot[g:object]{pointer} slot of the @class{g:object} class.
  @end{short}
  The @fun{g:object-pointer} function gets the foreign C pointer of a
  @class{g:object} instance.
  @begin[Examples]{dictionary}
    @begin{pre}
(setq label (make-instance 'gtk:label)) => #<GTK:LABEL {E2DB181@}>
(g:object-pointer label) => #.(SB-SYS:INT-SAP #X081BDAE0)
    @end{pre}
  @end{dictionary}
  @see-class{g:object}")

;; Abbreviation POINTER for the OBJECT-POINTER slot access function

(defmethod glib:pointer ((instance object))
  (object-pointer instance))

(defmethod (setf glib:pointer) (value (instance object))
  (setf (object-pointer instance) value))

;;; --- g:object-signal-handlers -----------------------------------------------

#+liber-documentation
(setf (documentation (liber:slot-documentation "signal-handlers" 'object) t)
 "An array of Lisp signals handlers which are connected to the instance.")

#+liber-documentation
(setf (liber:alias-for-function 'object-signal-handlers)
      "Accessor"
      (documentation 'object-signal-handlers 'function)
 "@version{2023-12-1}
  @argument[object]{a @class{g:object} instance}
  @argument[handlers]{an array with the signal handlers connected to
    @arg{object}}
  @begin{short}
    Returns the array of Lisp signal handlers which are connected with the
    @fun{g:signal-connect} function to a @class{g:object} instance.
  @end{short}
  @begin[Examples]{dictionary}
    @begin{pre}
(setq button (make-instance 'gtk:button))
=> #<GTK-BUTTON {E319359@}>
(g:signal-connect button \"clicked\" (lambda () ))
=> 27
(g:object-signal-handlers button)
=> #(#<FUNCTION (LAMBDA #) {E324855@}>)
(g:signal-connect button \"destroy\" (lambda () ))
=> 28
(g:object-signal-handlers button)
=> #(#<FUNCTION (LAMBDA #) {E324855@}> #<FUNCTION (LAMBDA #) {E336EDD@}>)
    @end{pre}
  @end{dictionary}
  @see-class{g:object}
  @see-function{g:signal-connect}")

;;; ----------------------------------------------------------------------------
;;; GInitiallyUnowned
;;;
;;; typedef struct _GObject GInitiallyUnowned;
;;;
;;; All the fields in the GInitiallyUnowned structure are private to the
;;; GInitiallyUnowned implementation and should never be accessed directly.
;;; ----------------------------------------------------------------------------

;; This class is unexported for the cl-cffi-gtk documentation.

(defclass initially-unowned (object)
  ()
  (:metaclass gobject-class)
  (:gname . "GInitiallyUnowned")
  (:initializer . "g_initially_unowned_get_type")
  (:documentation "Base class that has initial 'floating' reference."))

#+liber-documentation
(setf (documentation 'initially-unowned 'type)
 "@version{#2022-12-30}
  @begin{short}
    The @class{g:initially-unowned} class is derived from the @class{g:object}
    class.
  @end{short}
  The only difference between the two is that the initial reference of a
  @class{g:initially-unowned} object is flagged as a floating reference. This
  means that it is not specifically claimed to be \"owned\" by any code portion.

  The floating reference can be converted into an ordinary reference by
  calling the @code{g_object_ref_sink()} function. For already sunken objects,
  objects that do not have a floating reference anymore, the
  @code{g_object_ref_sink()} function is equivalent to the @code{g_object_ref()}
  function and returns a new reference. Since floating references are useful
  almost exclusively for C convenience, language bindings that provide automated
  reference and memory ownership maintenance, such as smart pointers
  or garbage collection, should not expose floating references in their API.
  @see-class{g:object}")

(export 'initially-unowned)

;;; ----------------------------------------------------------------------------

;; GC for weak pointers

(defvar *gobject-gc-hooks-lock*
        (bt:make-recursive-lock "gobject-gc-hooks-lock"))
(defvar *gobject-gc-hooks* nil) ; pointers to objects to be freed

;;; ----------------------------------------------------------------------------

(defun dispose-carefully (pointer)
  (handler-case
    (register-gobject-for-gc pointer)
    (error (e)
      (format t "Error in DISPOSE-CAREFULLY: ~A~%" e))))

(defmethod release ((obj object))
  (tg:cancel-finalization obj)
  (let ((ptr (object-pointer obj)))
    (setf (object-pointer obj) nil)
    (dispose-carefully ptr)))

(defun activate-gc-hooks ()
  (bt:with-recursive-lock-held (*gobject-gc-hooks-lock*)
    (when *gobject-gc-hooks*
      (log-for :gc "~&ACTIVATE-GC-HOOKS for: ~A~%" *gobject-gc-hooks*)
      (iter (for pointer in *gobject-gc-hooks*)
            (%object-remove-toggle-ref pointer
                                       (cffi:callback toggle-notify)
                                       (cffi:null-pointer)))
      (setf *gobject-gc-hooks* nil)))
  nil)

(defun register-gobject-for-gc (pointer)
  (bt:with-recursive-lock-held (*gobject-gc-hooks-lock*)
    (let ((locks-were-present (not (null *gobject-gc-hooks*))))
      (push pointer *gobject-gc-hooks*)
      (unless locks-were-present
        (log-for :gc "~&REGISTER-GOBJECT-FOR-GC: ~a~%" pointer)
        (glib:idle-add #'activate-gc-hooks)))))

;;; ----------------------------------------------------------------------------

;; If object was not created from lisp-side, we should ref it
;; If an object is regular object, we should not ref-sink it
;; If an object is GInitiallyUnowned, then it is created with a floating
;; reference, we should ref-sink it
;; A special case is GtkWindow: we should ref-sink it anyway

(defun should-ref-sink-at-creation (object)
  (let ((r (cond ;; not new objects should be ref_sunk
                 ((equal *current-object-from-pointer* (object-pointer object))
                  (log-for :gc "~&SHOULD-REF-SINK: object is from pointer~%")
                  t)
                 ;; g_object_new returns objects with ref=1,
                 ;; we should save this ref
                 ((eq object *current-creating-object*)
                  ;; but GInitiallyUnowned objects should be ref_sunk
                  (typep object 'initially-unowned))
                 (t t))))
    (log-for :gc "~&SHOULD-REF-SINK: ~a => ~a~%" object r)
    r))

(defun register-gobject (object)
  (let ((pointer (object-pointer object)))
    (log-for :gc "~&REGISTER-GOBJECT: ~a, refcount: ~a ~a~%"
             object
             (ref-count object)
             (if (%object-is-floating pointer) "(floating)" ""))
    (when (should-ref-sink-at-creation object)
      (log-for :gc "~&REGISTER-GOBJECT: g:object-ref-sink ~a~%" object)
      (%object-ref-sink pointer))
    (setf (object-has-reference object) t)
    (setf (get-gobject-for-pointer-strong pointer) object)
    (%object-add-toggle-ref pointer
                            (cffi:callback toggle-notify)
                            (cffi:null-pointer))
    (%object-unref pointer)))

;;; ----------------------------------------------------------------------------

(defmethod initialize-instance :around ((obj object) &key)
  (when *currently-making-object-p*
    (setf *currently-making-object-p* t))
  (let ((*current-creating-object* obj))
    (log-for :subclass
             ":subclass INITIALIZE-INSTANCE :around creating ~a~%" obj)
    (call-next-method)))

(defmethod initialize-instance :after ((obj object) &key &allow-other-keys)
  (unless (slot-boundp obj 'pointer)
    (error "INITIALIZE-INIT: Pointer slot is not initialized for ~a" obj))
  (let* ((pointer (object-pointer obj))
         (s (format nil "~a" obj)))
    (tg:finalize obj
                 (lambda ()
                   (log-for :gc
                            "~&FINALIZE: ~a ~a queued for GC, refcount: ~a~%"
                            (type-name (type-from-instance pointer))
                            pointer
                            (ref-count pointer))
                   (handler-case
                     (dispose-carefully pointer)
                     (error (e)
                       (format t "Error in finalizer for ~A: ~A~%" s e))))))
  (register-gobject obj)
  (activate-gc-hooks))

;;; ----------------------------------------------------------------------------

;; TODO: This function is not used.

(cffi:defcallback gobject-weak-ref-finalized :void
    ((data :pointer) (pointer :pointer))
  (declare (ignore data))
  (log-for :gc "~&~A is weak-ref-finalized with ~A refs~%"
           pointer (ref-count pointer))
  (remhash (cffi:pointer-address pointer) *foreign-gobjects-weak*)
  (when (get-gobject-for-pointer-strong pointer)
;       (gethash (cffi:pointer-address pointer) *foreign-gobjects-strong*)
    (warn "GObject at ~A was weak-ref-finalized while still holding lisp-side ~
           strong reference to it"
          pointer)
    (log-for :gc "~&GObject at ~A was weak-ref-finalized while still holding ~
                  lisp-side strong reference to it"
             pointer))
;  (remhash (cffi:pointer-address pointer) *foreign-gobjects-strong*)
   (rem-gobject-for-pointer-strong pointer)
  )

;;; ----------------------------------------------------------------------------

;; Translate a pointer to the corresponding Lisp object. If a Lisp object does
;; not exist, create the Lisp object.
(defun get-or-create-gobject-for-pointer (pointer)
  (log-for :gc "~&GET-OR-CREATE-GOBJECT-FOR-POINTER: ~A~%" pointer)
  (unless (cffi:null-pointer-p pointer)
    (or (get-gobject-for-pointer pointer)
        (create-gobject-from-pointer pointer))))

;;; ----------------------------------------------------------------------------

;; Create a Lisp object from a C pointer to an existing C object.

(defun create-gobject-from-pointer (pointer)
  (flet (;; Get the corresponing lisp type for a GType
         (get-gobject-lisp-type (gtype)
            (iter (while (not (null gtype)))
                  (for lisp-type = (glib:symbol-for-gtype
                                       (glib:gtype-name gtype)))
                  (when lisp-type (return lisp-type))
                  (setf gtype (type-parent gtype)))))
    (let* ((gtype (type-from-instance pointer))
           (lisp-type (get-gobject-lisp-type gtype)))
      (log-for :gc "~&CREATE-GOBJECR-FROM-POINTER: ~a~%" pointer)
      (unless lisp-type
        (error "Type ~A is not registered with REGISTER-OBJECT-TYPE"
               (glib:gtype-name gtype)))
      (let ((*current-object-from-pointer* pointer))
        (make-instance lisp-type :pointer pointer)))))

;;; ----------------------------------------------------------------------------

;; Define the type foreign-g-object-type and the type transformation rules.

(cffi:define-foreign-type foreign-g-object-type ()
  ((sub-type :reader sub-type
             :initarg :sub-type
             :initform 'object)
   (already-referenced :reader foreign-g-object-type-already-referenced
                       :initarg :already-referenced
                       :initform nil))
  (:actual-type :pointer))

(cffi:define-parse-method object (&rest args)
  (let* ((sub-type (first (remove-if #'keywordp args)))
         (flags (remove-if-not #'keywordp args))
         (already-referenced (not (null (find :already-referenced flags)))))
    (make-instance 'foreign-g-object-type
                   :sub-type sub-type
                   :already-referenced already-referenced)))

(defmethod cffi:translate-to-foreign (object (type foreign-g-object-type))
  (let ((pointer nil))
    (cond ((null object)
           (cffi:null-pointer))
          ((cffi:pointerp object)
           object)
          ((null (setf pointer (object-pointer object)))
           (error "Object ~A has been disposed" object))
          ((typep object 'object)
           (when (sub-type type)
             (assert (typep object (sub-type type))
                      nil
                      "Object ~A is not a subtype of ~A" object (sub-type type)))
           pointer)
          (t (error "Object ~A is not translatable as GObject*" object)))))

(defmethod cffi:translate-from-foreign (pointer (type foreign-g-object-type))
  (let ((object (get-or-create-gobject-for-pointer pointer)))
    (when (and object
               (foreign-g-object-type-already-referenced type))
      (%object-unref (object-pointer object)))
    object))

;;; ----------------------------------------------------------------------------

;; Moved to gobject.gobject-class.lisp

;(define-condition property-access-error (error)
;  ((property-name :initarg :property-name
;                  :reader property-access-error-property-name)
;   (class-name :initarg :class-name
;               :reader property-access-error-class-name)
;   (message :initarg :message :reader property-access-error-message))
;  (:report (lambda (condition stream)
;             (format stream "Error accessing property '~A' on class '~A': ~A"
;                     (property-access-error-property-name condition)
;                     (property-access-error-class-name condition)
;                     (property-access-error-message condition)))))

;(define-condition property-unreadable-error (property-access-error)
;  ()
;  (:default-initargs :message "property is not readable"))

;(define-condition property-unwritable-error (property-access-error)
;  ()
;  (:default-initargs :message "property is not writable"))

;;; ----------------------------------------------------------------------------

;; Get the definition of a property for the GObject type. Both arguments are of
;; type string, e.g. (class-property-info "GtkLabel" "label")

;; TODO: Duplicates the implementation of OBJECT-CLASS-FIND-PROPERTY. But
;; we return a %PARAM-SPEC instance which is the Lisp side of a GParamSpec
;; instance. Improve the implementation of GParamSpec!?

(defun class-property-pspec (gtype name)
  (let ((class (type-class-ref gtype)))
    (when class
      (unwind-protect
        (let ((pspec (%object-class-find-property class name)))
          (unless (cffi:null-pointer-p pspec)
            (parse-g-param-spec pspec)))
        (type-class-unref class)))))

;; Get the type of a property NAME for a class of type GTYPE
;; Checks if the properties are readable or writeable

(defun class-property-type (gtype name &key assert-readable assert-writable)
  (let ((pspec (class-property-pspec gtype name)))
    (assert pspec
            nil
            "CLASS-PROPERTY-TYPE: Property ~a not registered for ~a object"
            name
            gtype)
    (when (and assert-readable
               (not (%param-spec-readable pspec)))
      (error 'property-unreadable-error
             :property-name name
             :class-name (type-name gtype)))
    (when (and assert-writable
               (not (%param-spec-writable pspec)))
      (error 'property-unwritable-error
             :property-name name
             :class-name (type-name gtype)))
    (%param-spec-type pspec)))

;;; ----------------------------------------------------------------------------

(defmethod make-instance ((class gobject-class) &rest initargs &key pointer)
  (log-for :subclass
           ":subclass MAKE-INSTANCE ~A ~{~A~^ ~})~%" class initargs)
  (ensure-finalized class)
  (let ((*currently-making-object-p* t))
    (if pointer
        (progn
          (assert (= (length initargs) 2)
                  nil
                  "POINTER can not be combined with other initargs (~A)"
                  initargs)
          (call-next-method))
        (let* ((default-initargs
                (iter (for (arg value) in (class-default-initargs class))
                      (nconcing (list arg value))))
               (effective-initargs (append initargs default-initargs))
               (pointer (create-gobject-from-class class effective-initargs)))
          (apply #'call-next-method class
                 :pointer pointer
                 effective-initargs)))))

;;; ----------------------------------------------------------------------------

(defmethod initialize-instance ((instance object) &rest initargs
                                                  &key &allow-other-keys)
  (let ((filtered-initargs (filter-initargs-by-class (class-of instance)
                                                     initargs)))
    (apply #'call-next-method instance filtered-initargs)))

;;; ----------------------------------------------------------------------------

(defun create-gobject-from-class (class initargs)
  (when (gobject-class-interface-p class)
    (error "Trying to create instance of GInterface '~A' (class '~A')"
           (gobject-class-gname class)
           (class-name class)))
  (let (arg-names arg-values arg-types nc-setters nc-arg-values)
    (declare (dynamic-extent arg-names arg-values arg-types
                             nc-setters nc-arg-values))
    (iter (for (arg-name arg-value) on initargs by #'cddr)
          (for slot = (find arg-name
                            (class-slots class)
                            :key 'slot-definition-initargs
                            :test 'member))
          (when (and slot (typep slot 'gobject-effective-slot-definition)))
          (typecase slot
           (gobject-property-effective-slot-definition
            (push (gobject-property-effective-slot-definition-g-property-name slot)
                  arg-names)
            (push arg-value arg-values)
            (push (gobject-effective-slot-definition-g-property-type slot)
                  arg-types))
           (gobject-fn-effective-slot-definition
            (push (gobject-fn-effective-slot-definition-g-setter-fn slot)
                  nc-setters)
            (push arg-value nc-arg-values))))
    (let ((object (call-gobject-constructor (gobject-class-gname class)
                                            arg-names
                                            arg-values
                                            arg-types)))
      (iter (for fn in nc-setters)
            (for value in nc-arg-values)
            (funcall fn object value))
      object)))

;;; ----------------------------------------------------------------------------

(defun call-gobject-constructor (object-type args-names args-values
                                 &optional args-types)
  (unless args-types
    (setf args-types
          (mapcar (lambda (name)
                    (class-property-type object-type name))
                  args-names)))
  (let ((args-count (length args-names)))
    (cffi:with-foreign-object (params '(:struct %parameter) args-count)
      (iter (for i from 0 below args-count)
            (for arg-name in args-names)
            (for arg-value in args-values)
            (for arg-type in args-types)
            (for arg-gtype = (if arg-type
                                 arg-type
                                 (class-property-type object-type arg-name)))
            (for param = (cffi:mem-aptr params
                                        '(:struct %parameter) i))
            (setf (cffi:foreign-slot-value param
                                           '(:struct %parameter) 'name)
                  arg-name)
            (set-g-value (cffi:foreign-slot-pointer param
                                                    '(:struct %parameter)
                                                    'value)
                         arg-value
                         arg-gtype
                         :zero-gvalue t))
      (unwind-protect
        (%object-newv object-type args-count params)
        (iter (for i from 0 below args-count)
              (for param = (cffi:mem-aptr params '(:struct %parameter) i))
              (cffi:foreign-string-free
                  (cffi:mem-ref
                      (cffi:foreign-slot-pointer param
                                                 '(:struct %parameter)
                                                 'name)
                      :pointer))
              (value-unset (cffi:foreign-slot-pointer param
                                                      '(:struct %parameter)
                                                      'value)))))))

;;; ----------------------------------------------------------------------------
;;; GObjectClass                                            not exported
;;; ----------------------------------------------------------------------------

(cffi:defcstruct object-class
  (:type-class (:pointer (:struct type-class)))
  (:construct-properties :pointer)
  (:constructor :pointer)
  (:set-property :pointer)
  (:get-property :pointer)
  (:dispose :pointer)
  (:finalize :pointer)
  (:dispatch-properties-changed :pointer)
  (:notify :pointer)
  (:constructed :pointer)
  (:pdummy :pointer :count 7))

#+liber-documentation
(setf (liber:alias-for-symbol 'object-class)
      "CStruct"
      (liber:symbol-documentation 'object-class)
 "@version{#2021-9-9}
  @short{The class structure for the @class{g:object} type.}
  @begin{pre}
(cffi:defcstruct object-class
  (:type-class g-type-class)
  (:construct-properties :pointer)
  (:constructor :pointer)
  (:set-property :pointer)
  (:get-property :pointer)
  (:dispose :pointer)
  (:finalize :pointer)
  (:dispatch-properties-changed :pointer)
  (:notify :pointer)
  (:constructed :pointer)
  (:pdummy :pointer :count 7))
  @end{pre}
  @begin[code]{table}
    @begin[:type-class]{entry}
      The parent class.
    @end{entry}
    @begin[:constructor]{entry}
      The @code{constructor} function is called by the @fun{object-new}
      function to complete the object initialization after all the
      construction properties are set. The first thing a @code{constructor}
      implementation must do is chain up to the @code{constructor} of the
      parent class. Overriding @code{constructor} should be rarely needed,
      e.g. to handle construct properties, or to implement singletons.
    @end{entry}
    @begin[:set-property]{entry}
      The generic setter for all properties of this type. Should be overridden
      for every type with properties. Implementations of @code{set-property}
      do not need to emit property change notification explicitly, this is
      handled by the type system.
    @end{entry}
    @begin[:get-property]{entry}
      The generic getter for all properties of this type. Should be overridden
      for every type with properties.
    @end{entry}
    @begin[:dispose]{entry}
      The @code{dispose} function is supposed to drop all references to other
      objects, but keep the instance otherwise intact, so that client method
      invocations still work. It may be run multiple times (due to reference
      loops). Before returning, @code{dispose} should chain up to the
      @code{dispose} method of the parent class.
    @end{entry}
    @begin[:finalize]{entry}
      Instance finalization function, should finish the finalization of the
      instance begun in @code{dispose} and chain up to the @code{finalize}
      method of the parent class.
    @end{entry}
    @begin[:dispatch-properties-changed]{entry}
      Emits property change notification for a bunch of properties. Overriding
      @code{dispatch-properties-changed} should be rarely needed.
    @end{entry}
    @begin[:notify]{entry}
      The class closure for the notify signal.
    @end{entry}
    @begin[:constructed]{entry}
      The @code{constructed} function is called by the @fun{object-new}
      function as the final step of the object creation process. At
      the point of the call, all construction properties have been set on the
      object. The purpose of this call is to allow for object initialisation
      steps that can only be performed after construction properties have been
      set. @code{constructed} implementors should chain up to the
      @code{constructed} call of their parent class to allow it to complete
      its initialisation.
    @end{entry}
  @end{table}
  @see-class{g:object}")

;; Accessors for the slots of the GObjectClass structure
(defun object-class-get-property (class)
  (cffi:foreign-slot-value class '(:struct object-class) :get-property))

(defun (setf object-class-get-property) (value class)
  (setf (cffi:foreign-slot-value class '(:struct object-class) :get-property)
        value))

(defun object-class-set-property (class)
  (cffi:foreign-slot-value class '(:struct object-class) :set-property))

(defun (setf object-class-set-property) (value class)
  (setf (cffi:foreign-slot-value class '(:struct object-class) :set-property)
        value))

;;; ----------------------------------------------------------------------------
;;; GObjectConstructParam                                   not exported
;;; ----------------------------------------------------------------------------

;; This structure is not needed in the implementation of the Lisp library
;; and is not exported.

(cffi:defcstruct object-construct-param
  (:pspec (:pointer (:struct param-spec)))
  (:value (:pointer (:struct value))))

#+liber-documentation
(setf (liber:alias-for-symbol 'object-construct-param)
      "CStruct"
      (liber:symbol-documentation 'object-construct-param)
 "@version{#2020-2-17}
  @begin{short}
    The @symbol{g:object-construct-param} structure is an auxiliary structure
    used to hand @symbol{g:param-spec}/@symbol{g:value} pairs to the constructor
    of a @symbol{g:object-class} structure.
  @end{short}
  @begin{pre}
(cffi:defcstruct object-construct-param
  (:pspec (:pointer param-spec))
  (:value (:pointer value)))
  @end{pre}
  @begin[code]{table}
    @entry[:pspec]{The @symbol{param-spec} instance of the construct
      parameter.}
    @entry[:value]{The value to set the parameter to.}
  @end{table}
  @see-symbol{object-class}
  @see-symbol{param-spec}
  @see-symbol{value}")

;;; ----------------------------------------------------------------------------
;;; GInitiallyUnownedClass
;;;
;;; typedef struct _GObjectClass GInitiallyUnownedClass;
;;;
;;; The class structure for the GInitiallyUnowned type.
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; GObjectGetPropertyFunc ()
;;;
;;; void (*GObjectGetPropertyFunc) (GObject *object,
;;;                                 guint property_id,
;;;                                 GValue *value,
;;;                                 GParamSpec *pspec);
;;;
;;; The type of the get_property function of GObjectClass.
;;;
;;; object :
;;;     a GObject
;;;
;;; property_id :
;;;     the numeric id under which the property was registered with
;;;     g_object_class_install_property().
;;;
;;; value :
;;;     a GValue to return the property value in
;;;
;;; pspec :
;;;     the GParamSpec describing the property
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; GObjectSetPropertyFunc ()
;;;
;;; void (*GObjectSetPropertyFunc) (GObject *object,
;;;                                 guint property_id,
;;;                                 const GValue *value,
;;;                                 GParamSpec *pspec);
;;;
;;; The type of the set_property function of GObjectClass.
;;;
;;; object :
;;;     a GObject
;;;
;;; property_id :
;;;     the numeric id under which the property was registered with
;;;     g_object_class_install_property().
;;;
;;; value :
;;;     the new value for the property
;;;
;;; pspec :
;;;     the GParamSpec describing the property
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; GObjectFinalizeFunc ()
;;;
;;; void (*GObjectFinalizeFunc) (GObject *object);
;;;
;;; The type of the finalize function of GObjectClass.
;;;
;;; object :
;;;     the GObject being finalized
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; G_TYPE_IS_OBJECT
;;; ----------------------------------------------------------------------------

(defun type-is-object (gtype)
 #+liber-documentation
 "@version{2023-12-1}
  @argument[gtype]{a @class{g:type-t} type ID to check}
  @begin{return}
    @em{False} or @em{true}, indicating whether the @arg{gtype} argument is a
    @code{\"GObject\"} type.
  @end{return}
  @begin{short}
    Checks if the passed in type ID is a @code{\"GObject\"} type or derived
    from it.
  @end{short}
  @begin[Examples]{dictionary}
    @begin{pre}
(g:type-is-object \"GtkLabel\") => T
(g:type-is-object \"GtkActionable\") => NIL
(g:type-is-object \"gboolean\") => NIL
(g:type-is-object \"unknown\") => NIL
(g:type-is-object nil) => NIL
    @end{pre}
  @end{dictionary}
  @see-class{g:type-t}"
  (and (not (type-is-a gtype (glib:gtype "GInterface")))
       (type-is-a gtype (glib:gtype "GObject"))))

(export 'type-is-object)

;;; ----------------------------------------------------------------------------
;;; G_OBJECT()
;;;
;;; #define G_OBJECT(object)
;;;         (G_TYPE_CHECK_INSTANCE_CAST ((object), G_TYPE_OBJECT, GObject))
;;;
;;; Casts a GObject or derived pointer into a (GObject*) pointer. Depending on
;;; the current debugging level, this function may invoke certain runtime checks
;;; to identify invalid casts.
;;;
;;; object :
;;;     Object which is subject to casting.
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; G_IS_OBJECT
;;; ----------------------------------------------------------------------------

(defun is-object (object)
 #+liber-documentation
 "@version{2023-12-1}
  @argument[object]{a valid @symbol{g:type-instance} instance to check}
  @begin{short}
    Checks whether the @arg{object} argument is of @code{\"GObject\"} type
    or derived from it.
  @end{short}
  @begin[Example]{dictionary}
    @begin{pre}
(g:is-object (make-instance 'gtk-button)) => T
    @end{pre}
  @end{dictionary}
  @see-class{g:object}
  @see-symbol{g:type-instance}"
  (type-check-instance-type object (glib:gtype "GObject")))

(export 'is-object)

;;; ----------------------------------------------------------------------------
;;; G_OBJECT_CLASS()
;;;
;;; #define G_OBJECT_CLASS(class)
;;;         (G_TYPE_CHECK_CLASS_CAST ((class), G_TYPE_OBJECT, GObjectClass))
;;;
;;; Casts a derived GObjectClass structure into a GObjectClass structure.
;;;
;;; class :
;;;     a valid GObjectClass
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; G_IS_OBJECT_CLASS                                       not exported
;;; ----------------------------------------------------------------------------

(defun is-object-class (class)
 #+liber-documentation
 "@version{#2021-9-9}
  @argument[class]{a foreign pointer to a @symbol{object-class} instance}
  @begin{short}
    Checks whether the @arg{class} argument is a @symbol{object-class}
    instance of type @code{\"GObject\"} or derived.
  @end{short}
  @begin[Examples]{dictionary}
    @begin{pre}
(g:object-class (make-instance 'gtk-button))
=> #.(SB-SYS:INT-SAP #X557BB1322590)
(g:is-object-class *) => T
    @end{pre}
  @end{dictionary}
  @see-class{g:object}
  @see-symbol{object-class}"
  (type-check-class-type class (glib:gtype "GObject")))

;;; ----------------------------------------------------------------------------
;;; G_OBJECT_GET_CLASS                                      not exported
;;; ----------------------------------------------------------------------------

(defun object-class (object)
 #+liber-documentation
 "@version{#2021-9-9}
  @argument[object]{a @class{g:object} instance}
  @return{The foreign pointer to the @symbol{object-class} instance.}
  @short{Gets the class instance associated to a @class{g:object} instance.}
  @begin[Examples]{dictionary}
    @begin{pre}
(g:object-class (make-instance 'gtk-button))
=> #.(SB-SYS:INT-SAP #X557BB1322590)
    @end{pre}
  @end{dictionary}
  @see-class{g:object}
  @see-symbol{object-class}"
  (type-instance-class object))

;;; ----------------------------------------------------------------------------
;;; G_OBJECT_TYPE
;;; ----------------------------------------------------------------------------

(defun object-type (object)
 #+liber-documentation
 "@version{2023-12-1}
  @argument[object]{a @class{g:object} instance to return the type ID for}
  @return{The @class{g:type-t} type ID of the @arg{object} argument.}
  @begin{short}
    Gets the type ID for the instance of an object.
  @end{short}
  Returns @code{nil} if the @arg{object} argument is @code{nil}. This function
  calls the @fun{g:type-from-instance} function to get the type for an object,
  but checks in addition for a non-@code{nil} argument.
  @begin[Examples]{dictionary}
    @begin{pre}
(g:object-type (make-instance 'gtk:label))
=> #S(GTYPE :name \"GtkLabel\" :id 134905144)
(g:object-type nil) => nil
    @end{pre}
  @end{dictionary}
  @see-class{g:object}
  @see-class{g:type-t}
  @see-function{g:object-type-name}
  @see-function{g:type-from-instance}"
  (when object
    (type-from-instance object)))

(export 'object-type)

;;; ----------------------------------------------------------------------------
;;; G_OBJECT_TYPE_NAME
;;; ----------------------------------------------------------------------------

(defun object-type-name (object)
 #+liber-documentation
 "@version{2023-12-1}
  @argument[object]{a @class{g:object} instance to return the type name for}
  @return{The string with type name of the @arg{object} argument.}
  @begin{short}
    Gets the name of the type for an instance.
  @end{short}
  Returns @code{nil}, if the @arg{object} argument is @code{nil}. This function
  calls the @fun{g:type-from-instance} and @fun{g:type-name} functions to get
  the name, but checks for a non-@code{nil} argument.
  @begin[Examples]{dictionary}
    @begin{pre}
(g:object-type-name (make-instance 'gtk:label)) => \"GtkLabel\"
    @end{pre}
    This is equivalent to:
    @begin{pre}
(g:type-name (g:type-from-instance (make-instance 'gtk:label))) => \"GtkLabel\"
    @end{pre}
  @end{dictionary}
  @see-class{g:object}
  @see-function{g:object-type}
  @see-function{g:type-name}
  @see-function{g:type-from-instance}"
  (when object
    (type-name (type-from-instance object))))

(export 'object-type-name)

;;; ----------------------------------------------------------------------------
;;; G_OBJECT_CLASS_TYPE                                     not exported
;;; ----------------------------------------------------------------------------

(defun object-class-type (class)
 #+liber-documentation
 "@version{#2021-9-9}
  @argument[class]{a foreign pointer to a @symbol{object-class} instance}
  @return{The @class{type-t} type ID of the @arg{class} argument.}
  @short{Gets the type ID of a class instance.}
  @begin[Examples]{dictionary}
    @begin{pre}
(g:object-class-type (g:type-class-ref \"GtkLabel\"))
=> #<GTYPE :name \"GtkLabel\" :id 93989740834480>
    @end{pre}
  @end{dictionary}
  @see-class{g:type-t}
  @see-class{g:object}
  @see-symbol{g:object-class}"
  (type-from-class class))

;;; ----------------------------------------------------------------------------
;;; G_OBJECT_CLASS_NAME                                     not exported
;;; ----------------------------------------------------------------------------

(defun object-class-name (class)
 #+liber-documentation
 "@version{#2021-9-9}
  @argument[class]{a foreign pointer of a @symbol{object-class} instance}
  @return{The string with the type name of the @arg{class} argument.}
  @short{Returns the name of the type of a class instance.}
  @begin[Examples]{dictionary}
    @begin{pre}
(g:object-class-name (g:type-class-ref \"GtkLabel\")) => \"GtkLabel\"
    @end{pre}
  @end{dictionary}
  @see-class{g:object}
  @see-symbol{g:object-class}"
  (type-name (type-from-class class)))

;;; ----------------------------------------------------------------------------
;;; g_object_class_install_property                         not exported
;;; ----------------------------------------------------------------------------

;; For internal use and not exported.

(cffi:defcfun ("g_object_class_install_property" %object-class-install-property)
    :void
 #+liber-documentation
 "@version{#2020-2-17}
  @argument[class]{a @symbol{object-class} structure}
  @argument[property-id]{the ID for the new property}
  @argument[pspec]{a @symbol{param-spec} instance for the new property}
  @begin{short}
    Installs a new property. This is usually done in the class initializer.
  @end{short}

  Note that it is possible to redefine a property in a derived class, by
  installing a property with the same name. This can be useful at times, e.g.
  to change the range of allowed values or the default value.
  @see-class{g:object}
  @see-symbol{object-class}
  @see-symbol{param-spec}"
  (class (:pointer (:struct object-class)))
  (property-id :uint)
  (pspec (:pointer (:struct param-spec))))

;;; ----------------------------------------------------------------------------
;;; g_object_class_install_properties ()
;;;
;;; void g_object_class_install_properties (GObjectClass *oclass,
;;;                                         guint n_pspecs,
;;;                                         GParamSpec **pspecs);
;;;
;;; Installs new properties from an array of GParamSpecs. This is usually done
;;; in the class initializer.
;;;
;;; The property id of each property is the index of each GParamSpec in the
;;; pspecs array.
;;;
;;; The property id of 0 is treated specially by GObject and it should not be
;;; used to store a GParamSpec.
;;;
;;; This function should be used if you plan to use a static array of
;;; GParamSpecs and g_object_notify_by_pspec(). For instance, this class
;;; initialization:
;;;
;;;   enum {
;;;     PROP_0, PROP_FOO, PROP_BAR, N_PROPERTIES
;;;   };
;;;
;;;   static GParamSpec *obj_properties[N_PROPERTIES] = { NULL, };
;;;
;;;   static void
;;;   my_object_class_init (MyObjectClass *klass)
;;;   {
;;;     GObjectClass *gobject_class = G_OBJECT_CLASS (klass);
;;;
;;;     obj_properties[PROP_FOO] =
;;;       g_param_spec_int ("foo", "Foo", "Foo",
;;;                         -1, G_MAXINT,
;;;                         0,
;;;                         G_PARAM_READWRITE);
;;;
;;;     obj_properties[PROP_BAR] =
;;;       g_param_spec_string ("bar", "Bar", "Bar",
;;;                            NULL,
;;;                            G_PARAM_READWRITE);
;;;
;;;     gobject_class->set_property = my_object_set_property;
;;;     gobject_class->get_property = my_object_get_property;
;;;     g_object_class_install_properties (gobject_class,
;;;                                        N_PROPERTIES,
;;;                                        obj_properties);
;;;   }
;;;
;;; allows calling g_object_notify_by_pspec() to notify of property changes:
;;;
;;;   void
;;;   my_object_set_foo (MyObject *self, gint foo)
;;;   {
;;;     if (self->foo != foo)
;;;       {
;;;         self->foo = foo;
;;;         g_object_notify_by_pspec (G_OBJECT (self),
;;;                                   obj_properties[PROP_FOO]);
;;;       }
;;;    }
;;;
;;; oclass :
;;;     a GObjectClass
;;;
;;; n_pspecs :
;;;     the length of the GParamSpecs array
;;;
;;; pspecs :
;;;     the GParamSpecs array defining the new properties
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_object_class_find_property
;;; ----------------------------------------------------------------------------

(cffi:defcfun ("g_object_class_find_property" %object-class-find-property)
    (:pointer (:struct param-spec))
  (class (:pointer (:struct object-class)))
  (name :string))

(defun object-class-find-property (gtype name)
 #+liber-documentation
 "@version{2023-12-1}
  @argument[gtype]{a @class{g:type-t} type ID for an object class type}
  @argument[name]{a string with the name of the property to look up}
  @begin{return}
    The @symbol{g:param-spec} instance for the property, or @code{nil} if
    the object class does not have a property of that name.
  @end{return}
  @begin{short}
    Looks up the @symbol{g:param-spec} instance for a property of an object
    class type.
  @end{short}
  Signals an error if the @arg{gtype} type ID is not a @code{\"GObject\"} type.
  @begin[Example]{dictionary}
    Get the @symbol{g:param-spec} instance for the @slot[g:simple-action]{name}
    property of the @class{g:simple-action} object is looked up.
    @begin{pre}
(setq pspec (g:object-class-find-property \"GSimpleAction\" \"name\"))
=> #.(SB-SYS:INT-SAP #X560E17A46220)
(g:param-spec-name pspec) => \"name\"
(g:param-spec-type pspec) => #<GTYPE :name \"GParamString\" :id 94618525293072>
(g:param-spec-value-type pspec) => #<GTYPE :name \"gchararray\" :id 64>
    @end{pre}
  @end{dictionary}
  @see-class{g:object}
  @see-class{g:type-t}
  @see-symbol{g:param-spec}
  @see-function{g:object-class-list-properties}"
  (assert (type-is-object gtype)
          nil
          "G:OBJECT-CLASS-FIND-PROPERTY: ~a is not a GObject" gtype)
  (let ((class (type-class-ref gtype)))
    (unwind-protect
      (let ((pspec (%object-class-find-property class name)))
        (when (not (cffi:null-pointer-p pspec)) pspec))
      (type-class-unref class))))

(export 'object-class-find-property)

;;; ----------------------------------------------------------------------------
;;; g_object_class_list_properties
;;; ----------------------------------------------------------------------------

(cffi:defcfun ("g_object_class_list_properties" %object-class-list-properties)
    (:pointer (:pointer (:struct param-spec)))
  (class (:pointer (:struct object-class)))
  (n-props (:pointer :uint)))

(defun object-class-list-properties (gtype)
 #+liber-documentation
 "@version{2023-12-1}
  @argument[gtype]{a @class{g:type-t} type ID of an object class}
  @return{The list of @symbol{g:param-spec} instances.}
  @begin{short}
    Gets a list of @symbol{g:param-spec} instances for all properties of an
    object class type.
  @end{short}
  Signals an error if the @arg{gtype} type ID is not a @code{\"GObject\"} type.
  @begin[Example]{dictionary}
    @begin{pre}
(mapcar #'g:param-spec-name
        (g:object-class-list-properties \"GApplication\"))
=> (\"application-id\" \"flags\" \"resource-base-path\" \"is-registered\"
    \"is-remote\" \"inactivity-timeout\" \"action-group\" \"is-busy\")
    @end{pre}
  @end{dictionary}
  @see-class{g:object}
  @see-class{g:type-t}
  @see-symbol{g:param-spec}
  @see-function{g:object-class-find-property}"
  (assert (type-is-object gtype)
          nil
          "G:OBJECT-CLASS-LIST-PROPERTIES: ~a is not a GObject" gtype)
  (let ((class (type-class-ref gtype)))
    (unwind-protect
      (cffi:with-foreign-object (n-props :uint)
        (let ((pspecs (%object-class-list-properties class n-props)))
          (unwind-protect
            (iter (for count from 0 below (cffi:mem-ref n-props :uint))
                  (for pspec = (cffi:mem-aref pspecs :pointer count))
                  (collect pspec))
          (glib:free pspecs))))
      (type-class-unref class))))

(export 'object-class-list-properties)

;;; ----------------------------------------------------------------------------
;;; g_object_class_override_property                        not exported
;;; ----------------------------------------------------------------------------

(cffi:defcfun ("g_object_class_override_property"
                %object-class-override-property) :void
 #+liber-documentation
 "@version{#2020-2-17}
  @argument[class]{a @symbol{object-class} structure}
  @argument[property-id]{the new property ID}
  @argument[name]{the name of a property registered in a parent class or in an
    interface of this class}
  @begin{short}
    Registers @arg{property-id} as referring to a property with the name
    @arg{name} in a parent class or in an interface implemented by @arg{class}.
  @end{short}
  This allows this class to override a property implementation in a parent class
  or to provide the implementation of a property from an interface.
  @begin[Note]{dictionary}
    Internally, overriding is implemented by creating a property of type
    @code{GParamSpecOverride}; generally operations that query the properties of
    the object class, such as the functions @fun{object-class-find-property}
    or @fun{object-class-list-properties} will return the overridden property.
    However, in one case, the @code{construct_properties} argument of the
    constructor virtual function, the @code{GParamSpecOverride} is passed
    instead, so that the @code{param_id} field of the @symbol{param-spec}
    instance will be correct. For virtually all uses, this makes no difference.
    If you need to get the overridden property, you can call the
    @fun{param-spec-get-redirect-target} function.
  @end{dictionary}
  @see-class{g:object}
  @see-symbol{g:object-class}
  @see-function{g:object-class-find-property}
  @see-function{g:object-class-list-properties}
  @see-function{g:param-spec-get-redirect-target}"
  (class (:pointer (:struct object-class)))
  (property-id :uint)
  (name :string))

;;; ----------------------------------------------------------------------------
;;; g_object_interface_install_property                     not exported
;;; ----------------------------------------------------------------------------

(cffi:defcfun ("g_object_interface_install_property"
               %object-interface-install-property) :void
 #+liber-documentation
 "@version{#2020-2-17}
  @argument[iface]{any interface vtable for the interface, or the default
    vtable for the interface}
  @argument[pspec]{a @symbol{param-spec} instance for the new property}
  @begin{short}
    Add a property to an interface; this is only useful for interfaces that are
    added to GObject-derived types.
  @end{short}
  Adding a property to an interface forces all objects classes with that
  interface to have a compatible property. The compatible property could be a
  newly created @symbol{param-spec} instance, but normally the
  @fun{object-class-override-property} function will be used so that the
  object class only needs to provide an implementation and inherits the property
  description, default value, bounds, and so forth from the interface
  property.

  This function is meant to be called from the interface's default vtable
  initialization function (the @code{class_init} member of
  @symbol{type-info}.) It must not be called after after @code{class_init} has
  been called for any object types implementing this interface.
  @see-class{g:object}
  @see-symbol{g:param-spec}
  @see-symbol{g:type-info}
  @see-function{g:object-class-override-property}"
  (iface :pointer)
  (pspec (:pointer (:struct param-spec))))

;;; ----------------------------------------------------------------------------
;;; g_object_interface_find_property
;;; ----------------------------------------------------------------------------

(cffi:defcfun ("g_object_interface_find_property"
               %object-interface-find-property) (:pointer (:struct param-spec))
  (iface (:pointer (:struct type-interface)))
  (name :string))

(defun object-interface-find-property (gtype name)
 #+liber-documentation
 "@version{2023-12-1}
  @argument[gtype]{a @class{g:type-t} type ID for an interface type}
  @argument[name]{a string with the name of a property to lookup}
  @begin{return}
    The @symbol{g:param-spec} instance for the property of the interface type
    with, or @code{nil} if no such property exists.
  @end{return}
  @begin{short}
    Find the @symbol{g:param-spec} instance with the given property name for
    an interface type.
  @end{short}
  Signals an error if the @arg{gtype} type ID is not an @code{\"GInterface\"}
  type.
  @begin[Examples]{dictionary}
    @begin{pre}
(g:object-interface-find-property \"GAction\" \"name\")
=> #.(SB-SYS:INT-SAP #X55A6D24988C0)
(g:param-spec-name *)
=> \"name\"
(g:object-interface-find-property \"GAction\" \"unknown\")
=> NIL
    @end{pre}
  @end{dictionary}
  @see-class{g:type-t}
  @see-symbol{g:param-spec}"
  (assert (type-is-interface gtype)
          nil
          "G:OBJECT-INTERFACE-FIND-PROPERTY: ~a is not a GInterface type"
          gtype)
  (let ((iface (type-default-interface-ref gtype)))
    (unwind-protect
      (let ((pspec (%object-interface-find-property iface name)))
        (when (not (cffi:null-pointer-p pspec)) pspec))
      (type-default-interface-unref iface))))

(export 'object-interface-find-property)

;;; ----------------------------------------------------------------------------
;;; g_object_interface_list_properties
;;; ----------------------------------------------------------------------------

(cffi:defcfun ("g_object_interface_list_properties"
               %object-interface-list-properties)
    (:pointer (:struct param-spec))
  (iface (:pointer (:struct type-interface)))
  (n-props (:pointer :uint)))

(defun object-interface-list-properties (gtype)
 #+liber-documentation
 "@version{2023-12-1}
  @argument[gtype]{a @class{g:type-t} type ID of an interface type}
  @return{The list of @symbol{g:param-spec} instances for all properties of an
    interface type.}
  @begin{short}
    Lists the properties of an interface type.
  @end{short}
  Signals an error if the @arg{gtype} type ID is not an @code{\"GInterface\"}
  type.
  @begin[Example]{dictionary}
    @begin{pre}
(mapcar #'g:param-spec-name
        (g:object-interface-list-properties \"GAction\"))
=> (\"enabled\" \"name\" \"parameter-type\" \"state\" \"state-type\")
    @end{pre}
  @end{dictionary}
  @see-class{g:type-t}
  @see-symbol{g:param-spec}"
  (assert (type-is-interface gtype)
          nil
          "G:OBJECT-INTERFACE-LIST-PROPERTIES: ~a is not a GInterface type"
          gtype)
  (let ((iface (type-default-interface-ref gtype)))
    (unwind-protect
      (cffi:with-foreign-object (n-props :uint)
        (let ((pspecs (%object-interface-list-properties iface n-props)))
          (unwind-protect
            (iter (for count from 0 below (cffi:mem-ref n-props :uint))
                  (for pspec = (cffi:mem-aref pspecs :pointer count))
                  (collect pspec))
            (glib:free pspecs))))
      (type-default-interface-unref iface))))

(export 'object-interface-list-properties)

;;; ----------------------------------------------------------------------------
;;; g_object_new
;;; ----------------------------------------------------------------------------

(defun object-new (gtype &rest args)
 #+liber-documentation
 "@version{2023-12-1}
  @argument[gtype]{a @class{g:type-t} type ID of the @class{g:object} subtype
    to instantiate}
  @argument[args]{pairs of the property keyword and value}
  @begin{short}
    Creates a new instance of a @class{g:object} subtype and sets its
    properties.
  @end{short}
  Construction parameters which are not explicitly specified are set to their
  default values.
  @begin[Note]{dictionary}
    In the Lisp implementation this function calls the @code{make-instance}
    method to create the new instance.
  @end{dictionary}
  @begin[Examples]{dictionary}
    @begin{pre}
(g:object-new \"GtkButton\" :label \"text\" :margin 6)
=> #<GTK:BUTTON {D941381@}>
    @end{pre}
    This is equivalent to:
    @begin{pre}
(make-instance 'gtk:button :label \"text\" :margin 6)
=> #<GTK:BUTTON {D947381@}>
    @end{pre}
  @end{dictionary}
  @see-class{g:object}
  @see-class{g:type-t}"
  (let ((symbol (glib:symbol-for-gtype gtype)))
    (apply 'make-instance symbol args)))

(export 'object-new)

;;; ----------------------------------------------------------------------------
;;; g_object_new_with_properties ()
;;;
;;; GObject *
;;; g_object_new_with_properties (GType object_type,
;;;                               guint n_properties,
;;;                               const char *names[],
;;;                               const GValue values[]);
;;;
;;; Creates a new instance of a GObject subtype and sets its properties using
;;; the provided arrays. Both arrays must have exactly n_properties elements,
;;; and the names and values correspond by index.
;;;
;;; Construction parameters (see G_PARAM_CONSTRUCT, G_PARAM_CONSTRUCT_ONLY)
;;; which are not explicitly specified are set to their default values.
;;;
;;; object_type :
;;;     the object type to instantiate
;;;
;;; n_properties :
;;;     the number of properties
;;;
;;; names :
;;;     the names of each property to be set.
;;;
;;; values :
;;;     the values of each property to be set.
;;;
;;; Returns :
;;;     a new instance of object_type .
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_object_newv                                           not exported
;;; ----------------------------------------------------------------------------

;; This function is called internally in the Lisp library to create an object
;; and is not exported.

(cffi:defcfun ("g_object_newv" %object-newv) :pointer
  (object-type type-t)
  (n-parameter :uint)
  (parameters :pointer))

;;; ----------------------------------------------------------------------------
;;; g_object_ref
;;; ----------------------------------------------------------------------------

(cffi:defcfun ("g_object_ref" %object-ref) :pointer
  (object :pointer))

(defun object-ref (object)
 #+liber-documentation
 "@version{2024-3-30}
  @argument[object]{a @class{g:object} instance}
  @return{The same @arg{object}.}
  @short{Increases the reference count of object.}
  @see-class{g:object}"
  (cffi:convert-from-foreign (%object-ref (object-pointer object)) 'object))

(export 'object-ref)

;;; ----------------------------------------------------------------------------
;;; g_object_unref
;;; ----------------------------------------------------------------------------

(cffi:defcfun ("g_object_unref" %object-unref) :void
  (object :pointer))

(defun object-unref (object)
 #+liber-documentation
 "@version{#2024-3-30}
  @argument[object]{a @class{g:object} instance}
  @begin{short}
    Decreases the reference count of @arg{object}.
  @end{short}
  When its reference count drops to 0, the object is finalized.
  @see-class{g:object}"
  (%object-unref (object-pointer object)))

(export 'object-unref)

;;; ----------------------------------------------------------------------------
;;; g_object_ref_sink                                       not exported
;;; ----------------------------------------------------------------------------

;; The memory management is done in the Lisp library. We do not export this
;; function.

(cffi:defcfun ("g_object_ref_sink" %object-ref-sink) :pointer
 #+liber-documentation
 "@version{#2020-2-17}
  @argument[object]{a @class{g:object} instance}
  @return{@arg{object}}
  @begin{short}
    Increase the reference count of @arg{object}, and possibly remove the
    floating reference, if @arg{object} has a floating reference.
  @end{short}
  In other words, if the @arg{object} is floating, then this call \"assumes
  ownership\" of the floating reference, converting it to a normal reference by
  clearing the floating flag while leaving the reference count unchanged. If
  the @arg{object} is not floating, then this call adds a new normal reference
  increasing the reference count by one.
  @see-class{g:object}"
  (object :pointer))

;;; ----------------------------------------------------------------------------
;;; g_set_object ()
;;;
;;; gboolean
;;; g_set_object (GObject **object_ptr,
;;;               GObject *new_object);
;;;
;;; Updates a GObject pointer to refer to new_object . It increments the
;;; reference count of new_object (if non-NULL), decrements the reference count
;;; of the current value of object_ptr (if non-NULL), and assigns new_object to
;;; object_ptr . The assignment is not atomic.
;;;
;;; object_ptr must not be NULL.
;;;
;;; A macro is also included that allows this function to be used without
;;; pointer casts. The function itself is static inline, so its address may
;;; vary between compilation units.
;;;
;;; One convenient usage of this function is in implementing property setters:
;;;
;;; void
;;; foo_set_bar (Foo *foo,
;;;              Bar *new_bar)
;;; {
;;;   g_return_if_fail (IS_FOO (foo));
;;;   g_return_if_fail (new_bar == NULL || IS_BAR (new_bar));
;;;
;;;   if (g_set_object (&foo->bar, new_bar))
;;;     g_object_notify (foo, "bar");
;;; }
;;;
;;; object_ptr :
;;;     a pointer to a GObject reference
;;;
;;; new_object :
;;;     a pointer to the new GObject to assign to it, or NULL to clear the
;;;     pointer.
;;;
;;; Returns :
;;;     TRUE if the value of object_ptr changed, FALSE otherwise
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_clear_object ()
;;;
;;; void g_clear_object (volatile GObject **object_ptr);
;;;
;;; Clears a reference to a GObject.
;;;
;;; object_ptr must not be NULL.
;;;
;;; If the reference is NULL then this function does nothing. Otherwise, the
;;; reference count of the object is decreased and the pointer is set to NULL.
;;;
;;; This function is threadsafe and modifies the pointer atomically, using
;;; memory barriers where needed.
;;;
;;; A macro is also included that allows this function to be used without
;;; pointer casts.
;;;
;;; object_ptr :
;;;     a pointer to a GObject reference
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; G_TYPE_INITIALLY_UNOWNED
;;;
;;; #define G_TYPE_INITIALLY_UNOWNED (g_initially_unowned_get_type())
;;;
;;; The type for GInitiallyUnowned.
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_object_is_floating                                    not exported
;;; ----------------------------------------------------------------------------

;; The memory management is done in the Lisp library. We do not export this
;; function.

(cffi:defcfun ("g_object_is_floating" %object-is-floating) :boolean
 #+liber-documentation
 "@version{#2020-2-17}
  @argument[object]{a @class{g:object} instance}
  @return{@em{True} if @arg{object} has a floating reference.}
  @begin{short}
    Checks whether @arg{object} has a floating reference.
  @end{short}
  @see-class{g:object}"
  (object :pointer))

;;; ----------------------------------------------------------------------------
;;; g_object_force_floating                                 not exported
;;; ----------------------------------------------------------------------------

;; The memory management is done in the Lisp library. We do not export this
;; function.

(cffi:defcfun ("g_object_force_floating" %object-force-floating) :void
 #+liber-documentation
 "@version{#2020-2-17}
  @argument[object]{a @class{g:object} instance}
  @begin{short}
    This function is intended for @class{g:object} implementations to re-enforce
    a floating object reference.
  @end{short}
  Doing this is seldom required: all @class{g:initially-unowned}'s are created
  with a floating reference which usually just needs to be sunken by calling
  the function @fun{g:object-ref-sink}.
  @see-class{g:object}
  @see-class{g:initially-unowned}
  @see-function{g:object-ref-sink}"
  (object :pointer))

;;; ----------------------------------------------------------------------------
;;; GWeakNotify ()
;;;
;;; void (*GWeakNotify) (gpointer data,
;;;                      GObject *where_the_object_was);
;;;
;;; A GWeakNotify function can be added to an object as a callback that gets
;;; triggered when the object is finalized. Since the object is already being
;;; finalized when the GWeakNotify is called, there's not much you could do with
;;; the object, apart from e.g. using its address as hash-index or the like.
;;;
;;; data :
;;;     data that was provided when the weak reference was established
;;;
;;; where_the_object_was :
;;;     the object being finalized
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_object_weak_ref                                       not exported
;;; ----------------------------------------------------------------------------

;; The memory management is done in the Lisp library. We do not export this
;; function.

(cffi:defcfun ("g_object_weak_ref" %object-weak-ref) :void
 #+liber-documentation
 "@version{#2020-2-17}
  @argument[object]{@class{g:object} instance to reference weakly}
  @argument[notify]{callback to invoke before the @arg{object} is freed}
  @argument[data]{extra data to pass to @arg{notify}}
  @begin{short}
    Adds a weak reference callback to an object.
  @end{short}
  Weak references are used for notification when an object is finalized. They
  are called \"weak references\" because they allow you to safely hold a pointer
  to an object without calling @fun{object-ref} (@fun{object-ref} adds a
  strong reference, that is, forces the object to stay alive).

  Note that the weak references created by this method are not thread-safe:
  they cannot safely be used in one thread if the object's last
  @fun{object-unref} might happen in another thread. Use @class{weak-ref} if
  thread-safety is required.
  @see-class{g:object}
  @see-function{object-ref}
  @see-function{object-unref}"
  (object :pointer)
  (notify :pointer)
  (data :pointer))

;;; ----------------------------------------------------------------------------
;;; g_object_weak_unref                                     not exported
;;; ----------------------------------------------------------------------------

;; The memory management is done in the Lisp library. We do not export this
;; function.

(cffi:defcfun ("g_object_weak_unref" %object-weak-unref) :void
 #+liber-documentation
 "@version{#2020-2-17}
  @argument[object]{@class{object} instance to remove a weak reference from}
  @argument[notify]{callback to search for}
  @argument[data]{data to search for}
  @begin{short}
    Removes a weak reference callback to an object.
  @end{short}
  @see-class{object}"
  (object :pointer)
  (notify :pointer)
  (data :pointer))

;;; ----------------------------------------------------------------------------
;;; g_object_add_weak_pointer ()
;;;
;;; void g_object_add_weak_pointer (GObject *object,
;;;                                 gpointer *weak_pointer_location);
;;;
;;; Adds a weak reference from weak_pointer to object to indicate that the
;;; pointer located at weak_pointer_location is only valid during the lifetime
;;; of object. When the object is finalized, weak_pointer will be set to NULL.
;;;
;;; Note that as with g_object_weak_ref(), the weak references created by this
;;; method are not thread-safe: they cannot safely be used in one thread if the
;;; object's last g_object_unref() might happen in another thread. Use GWeakRef
;;; if thread-safety is required.
;;;
;;; object :
;;;     The object that should be weak referenced.
;;;
;;; weak_pointer_location :
;;;     The memory address of a pointer.
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_object_remove_weak_pointer ()
;;;
;;; void g_object_remove_weak_pointer (GObject *object,
;;;                                    gpointer *weak_pointer_location);
;;;
;;; Removes a weak reference from object that was previously added using
;;; g_object_add_weak_pointer(). The weak_pointer_location has to match the one
;;; used with g_object_add_weak_pointer().
;;;
;;; object :
;;;     The object that is weak referenced.
;;;
;;; weak_pointer_location :
;;;     The memory address of a pointer.
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_set_weak_pointer ()
;;;
;;; gboolean
;;; g_set_weak_pointer (gpointer *weak_pointer_location,
;;;                     GObject *new_object);
;;;
;;; Updates a pointer to weakly refer to new_object . It assigns new_object to
;;; weak_pointer_location and ensures that weak_pointer_location will
;;; automaticaly be set to NULL if new_object gets destroyed. The assignment is
;;; not atomic. The weak reference is not thread-safe, see
;;; g_object_add_weak_pointer() for details.
;;;
;;; weak_pointer_location must not be NULL.
;;;
;;; A macro is also included that allows this function to be used without
;;; pointer casts. The function itself is static inline, so its address may
;;; vary between compilation units.
;;;
;;; One convenient usage of this function is in implementing property setters:
;;;
;;; void
;;; foo_set_bar (Foo *foo,
;;;              Bar *new_bar)
;;; {
;;;   g_return_if_fail (IS_FOO (foo));
;;;   g_return_if_fail (new_bar == NULL || IS_BAR (new_bar));
;;;
;;;   if (g_set_weak_pointer (&foo->bar, new_bar))
;;;     g_object_notify (foo, "bar");
;;; }
;;;
;;; weak_pointer_location :
;;;     the memory address of a pointer
;;;
;;; new_object :
;;;     a pointer to the new GObject to assign to it, or NULL to clear the
;;;     pointer.
;;;
;;; Returns :
;;;     TRUE if the value of weak_pointer_location changed, FALSE otherwise
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_clear_weak_pointer ()
;;;
;;; void
;;; g_clear_weak_pointer (gpointer *weak_pointer_location);
;;;
;;; Clears a weak reference to a GObject.
;;;
;;; weak_pointer_location must not be NULL.
;;;
;;; If the weak reference is NULL then this function does nothing. Otherwise,
;;; the weak reference to the object is removed for that location and the
;;; pointer is set to NULL.
;;;
;;; A macro is also included that allows this function to be used without
;;; pointer casts. The function itself is static inline, so its address may
;;; vary between compilation units.
;;;
;;; weak_pointer_location :
;;;     The memory address of a pointer
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; GToggleNotify ()
;;;
;;; void (*GToggleNotify) (gpointer data,
;;;                        GObject *object,
;;;                        gboolean is_last_ref);
;;;
;;; A callback function used for notification when the state of a toggle
;;; reference changes. See g_object_add_toggle_ref().
;;;
;;; data :
;;;     Callback data passed to g_object_add_toggle_ref()
;;;
;;; object :
;;;     The object on which g_object_add_toggle_ref() was called.
;;;
;;; is_last_ref :
;;;     TRUE if the toggle reference is now the last reference to the object.
;;;     FALSE if the toggle reference was the last reference and there are now
;;;     other references.
;;; ----------------------------------------------------------------------------

(cffi:defcallback toggle-notify :void
    ((data :pointer)
     (object :pointer)
     (is-last-ref :boolean))
  (declare (ignore data))
  (log-for :gc "~&TOGGLE-NOTIFY: ~A is now ~A with ~A refs~%"
           (get-gobject-for-pointer object)
           (if is-last-ref "weak pointer" "strong pointer")
           (ref-count object))
  (if is-last-ref
      (let ((obj (get-gobject-for-pointer-strong object)))
        (if obj
            (progn
              (rem-gobject-for-pointer-strong object)
              (setf (get-gobject-for-pointer-weak object) obj))
            (warn "TOGGLE-NOTIFY: ~a at ~a has no lisp-side (strong) reference"
                  (type-name (type-from-instance object))
                  object)))
      (let ((obj (get-gobject-for-pointer-weak object)))
        (unless obj
          (warn "TOGGLE-NOTIFY: ~a at ~a has no lisp-side (weak) reference"
                (type-name (type-from-instance object))
                object))
        (rem-gobject-for-pointer-weak object)
        (setf (get-gobject-for-pointer-strong object) obj))))

;;; ----------------------------------------------------------------------------
;;; g_object_add_toggle_ref                                 not exported
;;; ----------------------------------------------------------------------------

;; The memory management is done in the Lisp library. We do not export this
;; function.

(cffi:defcfun ("g_object_add_toggle_ref" %object-add-toggle-ref) :void
 #+liber-documentation
 "@version{#2020-2-17}
  @argument[object]{a @class{g:object} instance}
  @argument[notify]{a function to call when this reference is the last reference
    to the @arg{object}, or is no longer the last reference}
  @argument[data]{data to pass to notify}
  @begin{short}
    Increases the reference count of the @arg{object} by one and sets a callback
    to be called when all other references to the @arg{object} are dropped, or
    when this is already the last reference to the @arg{object} and another
    reference is established.
  @end{short}

  This functionality is intended for binding @arg{object} to a proxy object
  managed by another memory manager. This is done with two paired references:
  the strong reference added by the @fun{g:object-add-toggle-ref} function and
  a reverse reference to the proxy object which is either a strong reference or
  weak reference.

  The setup is that when there are no other references to @arg{object}, only a
  weak reference is held in the reverse direction from @arg{object} to the proxy
  object, but when there are other references held to @arg{object}, a strong
  reference is held. The @arg{notify} callback is called when the reference from
  @arg{object} to the proxy object should be toggled from strong to weak
  (@code{is_last_ref} @em{true}) or weak to strong (@code{is_last_ref}
  @code{nil}).

  Since a (normal) reference must be held to the object before calling the
  @fun{g:object-add-toggle-ref} function, the initial state of the reverse link
  is always strong.

  Multiple toggle references may be added to the same gobject, however if
  there are multiple toggle references to an object, none of them will ever be
  notified until all but one are removed. For this reason, you should only
  ever use a toggle reference if there is important state in the proxy object.
  @see-class{g:object}"
  (object :pointer)
  (notify :pointer)
  (data :pointer))

;;; ----------------------------------------------------------------------------
;;; g_object_remove_toggle_ref                              not exported
;;; ----------------------------------------------------------------------------

;; The memory management is done in the Lisp library. We do not export this
;; function.

(cffi:defcfun ("g_object_remove_toggle_ref" %object-remove-toggle-ref) :void
 #+liber-documentation
 "@version{#2020-2-17}
  @argument[object]{a @class{g:object} instance}
  @argument[notify]{a function to call when this reference is the last reference
    to the @arg{object}, or is no longer the last reference}
  @argument[data]{data to pass to @arg{notify}}
  @begin{short}
    Removes a reference added with the @fun{object-add-toggle-ref} function.
    The reference count of the @arg{object} is decreased by one.
  @end{short}
  @see-class{g:object}
  @see-function{object-add-toggle-ref}"
  (object :pointer)
  (notify :pointer)
  (data :pointer))

;;; ----------------------------------------------------------------------------
;;; g_object_connect ()
;;;
;;; gpointer g_object_connect (gpointer object,
;;;                            const gchar *signal_spec,
;;;                            ...);
;;;
;;; A convenience function to connect multiple signals at once.
;;;
;;; The signal specs expected by this function have the form
;;; "modifier::signal_name", where modifier can be one of the following:
;;;
;;; signal
;;;
;;;     equivalent to g_signal_connect_data (..., NULL, 0)
;;;
;;; object_signal, object-signal
;;;
;;;     equivalent to g_signal_connect_object (..., 0)
;;;
;;; swapped_signal, swapped-signal
;;;
;;;     equivalent to g_signal_connect_data (..., NULL, G_CONNECT_SWAPPED)
;;;
;;; swapped_object_signal, swapped-object-signal
;;;
;;;     equivalent to g_signal_connect_object (..., G_CONNECT_SWAPPED)
;;;
;;; signal_after, signal-after
;;;
;;;     equivalent to g_signal_connect_data (..., NULL, G_CONNECT_AFTER)
;;;
;;; object_signal_after, object-signal-after
;;;
;;;     equivalent to g_signal_connect_object (..., G_CONNECT_AFTER)
;;;
;;; swapped_signal_after, swapped-signal-after
;;;
;;;     equivalent to g_signal_connect_data (..., NULL,
;;;                                          G_CONNECT_SWAPPED |
;;;                                          G_CONNECT_AFTER)
;;;
;;; swapped_object_signal_after, swapped-object-signal-after
;;;
;;;   equivalent to g_signal_connect_object (..., G_CONNECT_SWAPPED |
;;;                                               G_CONNECT_AFTER)
;;;
;;;   menu->toplevel = g_object_connect (g_object_new (GTK_TYPE_WINDOW,
;;;                              "type", GTK_WINDOW_POPUP,
;;;                              "child", menu,
;;;                              NULL),
;;;                  "signal::event", gtk_menu_window_event, menu,
;;;                  "signal::size_request", gtk_menu_window_size_request, menu,
;;;                  "signal::destroy", gtk_widget_destroyed, &menu->toplevel,
;;;                  NULL);
;;;
;;; object :
;;;     a GObject
;;;
;;; signal_spec :
;;;     the spec for the first signal
;;;
;;; ... :
;;;     GCallback for the first signal, followed by data for the first signal,
;;;     followed optionally by more signal spec/callback/data triples, followed
;;;     by NULL
;;;
;;; Returns :
;;;     object
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_object_disconnect ()
;;;
;;; void g_object_disconnect (gpointer object,
;;;                           const gchar *signal_spec,
;;;                           ...);
;;;
;;; A convenience function to disconnect multiple signals at once.
;;;
;;; The signal specs expected by this function have the form "any_signal", which
;;; means to disconnect any signal with matching callback and data, or
;;; "any_signal::signal_name", which only disconnects the signal named
;;; "signal_name".
;;;
;;; object :
;;;     a GObject
;;;
;;; signal_spec :
;;;     the spec for the first signal
;;;
;;; ... :
;;;     GCallback for the first signal, followed by data for the first signal,
;;;     followed optionally by more signal spec/callback/data triples, followed
;;;     by NULL
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_object_set ()
;;;
;;; void g_object_set (gpointer object, const gchar *first_property_name, ...);
;;;
;;; Sets properties on an object.
;;;
;;; object :
;;;     a GObject
;;;
;;; first_property_name :
;;;     name of the first property to set
;;;
;;; ... :
;;;     value for the first property, followed optionally by more name/value
;;;     pairs, followed by NULL
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_object_setv ()
;;;
;;; void
;;; g_object_setv (GObject *object,
;;;                guint n_properties,
;;;                const gchar *names[],
;;;                const GValue values[]);
;;;
;;; Sets n_properties properties for an object . Properties to be set will be
;;; taken from values . All properties must be valid. Warnings will be emitted
;;; and undefined behaviour may result if invalid properties are passed in.
;;;
;;; object :
;;;     a GObject
;;;
;;; n_properties :
;;;     the number of properties
;;;
;;; names :
;;;     the names of each property to be set.
;;;
;;; values :
;;;     the values of each property to be set.
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_object_get ()
;;;
;;; void g_object_get (gpointer object, const gchar *first_property_name, ...);
;;;
;;; Gets properties of an object.
;;;
;;; In general, a copy is made of the property contents and the caller is
;;; responsible for freeing the memory in the appropriate manner for the type,
;;; for instance by calling g_free() or g_object_unref().
;;;
;;; Example 2. Using g_object_get()
;;;
;;; An example of using g_object_get() to get the contents of three properties -
;;; one of type G_TYPE_INT, one of type G_TYPE_STRING, and one of type
;;; G_TYPE_OBJECT:
;;;
;;;   gint intval;
;;;   gchar *strval;
;;;   GObject *objval;
;;;
;;;   g_object_get (my_object,
;;;                 "int-property", &intval,
;;;                 "str-property", &strval,
;;;                 "obj-property", &objval,
;;;                 NULL);
;;;
;;;   // Do something with intval, strval, objval
;;;
;;;   g_free (strval);
;;;   g_object_unref (objval);
;;;
;;; object :
;;;     a GObject
;;;
;;; first_property_name :
;;;     name of the first property to get
;;;
;;; ... :
;;;     return location for the first property, followed optionally by more
;;;     name/return location pairs, followed by NULL
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_object_getv ()
;;;
;;; void
;;; g_object_getv (GObject *object,
;;;                guint n_properties,
;;;                const gchar *names[],
;;;                GValue values[]);
;;;
;;; Gets n_properties properties for an object . Obtained properties will be set
;;; to values . All properties must be valid. Warnings will be emitted and
;;; undefined behaviour may result if invalid properties are passed in.
;;;
;;; object :
;;;     a GObject
;;;
;;; n_properties :
;;;     the number of properties
;;;
;;; names :
;;;     the names of each property to get.
;;;
;;; values :
;;;     the values of each property to get.
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_object_notify
;;; ----------------------------------------------------------------------------

(cffi:defcfun ("g_object_notify" object-notify) :void
 #+liber-documentation
 "@version{2023-12-1}
  @argument[object]{a @class{g:object} instance}
  @argument[name]{a string with the name of a property installed on the class
    of @arg{object}}
  @begin{short}
    Emits a @code{\"notify\"} signal for the property on the object.
  @end{short}
  @see-class{g:object}"
  (object object)
  (name :string))

(export 'object-notify)

;;; ----------------------------------------------------------------------------
;;; g_object_notify_by_pspec ()
;;;
;;; void g_object_notify_by_pspec (GObject *object, GParamSpec *pspec);
;;;
;;; Emits a "notify" signal for the property specified by pspec on object.
;;;
;;; This function omits the property name lookup, hence it is faster than
;;; g_object_notify().
;;;
;;; One way to avoid using g_object_notify() from within the class that
;;; registered the properties, and using g_object_notify_by_pspec() instead, is
;;; to store the GParamSpec used with g_object_class_install_property() inside a
;;; static array, e.g.:
;;;
;;;   enum
;;;   {
;;;     PROP_0,
;;;     PROP_FOO,
;;;     PROP_LAST
;;;   };
;;;
;;;   static GParamSpec *properties[PROP_LAST];
;;;
;;;   static void
;;;   my_object_class_init (MyObjectClass *klass)
;;;   {
;;;     properties[PROP_FOO] = g_param_spec_int ("foo", "Foo", "The foo",
;;;                                              0, 100,
;;;                                              50,
;;;                                              G_PARAM_READWRITE);
;;;     g_object_class_install_property (gobject_class,
;;;                                      PROP_FOO,
;;;                                      properties[PROP_FOO]);
;;;   }
;;;
;;; and then notify a change on the "foo" property with:
;;;
;;;   g_object_notify_by_pspec (self, properties[PROP_FOO]);
;;;
;;; object :
;;;     a GObject
;;;
;;; pspec :
;;;     the GParamSpec of a property installed on the class of object.
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_object_freeze_notify
;;; ----------------------------------------------------------------------------

(cffi:defcfun ("g_object_freeze_notify" object-freeze-notify) :void
 #+liber-documentation
 "@version{2023-12-1}
  @argument[object]{a @class{g:object} instance}
  @begin{short}
    Increases the freeze count on the object.
  @end{short}
  If the freeze count is non-zero, the emission of @code{\"notify\"} signals on
  the object is stopped. The signals are queued until the freeze count is
  decreased to zero. This is necessary for accessors that modify multiple
  properties to prevent premature notification while the object is still being
  modified.
  @see-class{g:object}
  @see-function{g:object-thaw-notify}"
  (object object))

(export 'object-freeze-notify)

;;; ----------------------------------------------------------------------------
;;; g_object_thaw_notify
;;; ----------------------------------------------------------------------------

(cffi:defcfun ("g_object_thaw_notify" object-thaw-notify) :void
 #+liber-documentation
 "@version{2023-12-1}
  @argument[object]{a @class{g:object} instance}
  @begin{short}
    Reverts the effect of a previous call to the @fun{g:object-freeze-notify}
    function.
  @end{short}
  The freeze count is decreased on the object and when it reaches zero, all
  queued @code{\"notify\"} signals are emitted. It is an error to call this
  function when the freeze count is zero.
  @see-class{g:object}
  @see-function{g:object-freeze-notify}"
  (object object))

(export 'object-thaw-notify)

;;; ----------------------------------------------------------------------------
;;; g_object_get_data
;;; g_object_set_data
;;; ----------------------------------------------------------------------------

(cffi:defcfun ("g_object_set_data" %object-set-data) :void
  (object object)
  (key :string)
  (data :pointer))

(defun (setf object-data) (data object key)
  (let ((ptr (%object-get-data object key)))
    (cond ((null data)
           ;; Remove data and free the stable-poiner
           (%object-set-data object key (cffi:null-pointer))
           (when (not (cffi:null-pointer-p ptr))
             (glib:free-stable-pointer ptr)))
          ((cffi:null-pointer-p ptr)
           (setf ptr (glib:allocate-stable-pointer data))
           (%object-set-data object key ptr))
          (t
           (setf (glib:get-stable-pointer-value ptr) data)
           (%object-set-data object key ptr)))
    data))

(cffi:defcfun ("g_object_get_data" %object-get-data) :pointer
  (object object)
  (key :string))

(defun object-data (object key)
 #+liber-documentation
 "@version{2024-5-13}
  @syntax{(g:object-data object key) => data}
  @syntax{(setf (g:object-data object key) data)}
  @argument[object]{a @class{g:object} instance containing the associations}
  @argument[key]{a string with the name of the key}
  @argument[data]{any Lisp object as data to associate with that key}
  @begin{short}
    Each object carries around a table of associations from strings to pointers.
  @end{short}
  The @fun{g:object-data} function gets a named field from the objects table of
  associations. The @setf{g:object-data} function sets an association. If the
  object already had an association with that name, the old association will be
  destroyed.
  @begin{examples}
    @begin{pre}
(defvar item (make-instance 'g:menu-item)) => ITEM
;; Set an integer
(setf (g:object-data item \"prop\") 123) => 123
(g:object-data item \"prop\") => 123
;; Set a Lisp list
(setf (g:object-data item \"prop\") '(a b c)) => (A B C)
(g:object-data item \"prop\") => (A B C)
;; Set a GObject
(setf (g:object-data item \"prop\") (make-instance 'g:menu-item))
=> #<GIO:MENU-ITEM {1001AAA263@}>
(g:object-data item \"prop\")
=> #<GIO:MENU-ITEM {1001AAA263@}>
;; Clear the association
(setf (g:object-data item \"prop\") nil) => nil
(g:object-data item \"prop\") => nil
    @end{pre}
  @end{examples}
  @see-class{g:object}"
  (let ((ptr (%object-get-data object key)))
    (when (not (cffi:null-pointer-p ptr))
      (glib:get-stable-pointer-value ptr))))

(export 'object-data)

;;; ----------------------------------------------------------------------------
;;; GDestroyNotify
;;; ----------------------------------------------------------------------------

(cffi:defcallback destroy-notify :void
    ((data :pointer))
  (let ((func (glib:get-stable-pointer-value data)))
    (unwind-protect
      (funcall func)
      (glib:free-stable-pointer data))))

#+liber-documentation
(setf (liber:alias-for-symbol 'destroy-notify)
      "Callback"
      (liber:symbol-documentation 'destroy-notify)
 "@version{2024-5-13}
  @syntax{lambda ()}
  @begin{short}
    Specifies the type of function which is called when a data element is
    destroyed.
  @end{short}
  The callback function takes no argument and has no return value.
  See the @fun{g:object-set-data-full} function for an example.
  @see-function{g:object-set-data-full}")

(export 'destroy-notify)

;;; ----------------------------------------------------------------------------
;;; g_object_set_data_full
;;; ----------------------------------------------------------------------------

(cffi:defcfun ("g_object_set_data_full" %object-set-data-full) :void
  (object object)
  (key :string)
  (data :pointer)
  (destroy :pointer))

(defun object-set-data-full (object key func)
 #+liber-documentation
 "@version{2024-5-13}
  @argument[object]{a @class{g:object} instance containing the associations}
  @argument[key]{a string with the name of the key}
  @argument[func]{a @symbol{g:destroy-notify} callback function}
  @begin{short}
    Like the @fun{g:object-data} function except it adds notification for
    when the association is destroyed, either by setting it to a different
    value or when the object is destroyed.
  @end{short}
  Note that the @arg{func} callback function is not called if the @arg{data}
  argument is @code{nil}.
  @begin{examples}
    Set a destroy notify callback function for a window. This function is
    called when the window is destroyed or when the data is set to @code{nil}.
    @begin{pre}
(g:object-set-data-full window \"about\"
                        (lambda ()
                          (gtk:window-destroy about)))
    @end{pre}
  @end{examples}
  @see-class{g:object}
  @see-symbol{g:destroy-notify}
  @see-function{g:object-data}"
  (%object-set-data-full object
                         key
                         (glib:allocate-stable-pointer func)
                         (cffi:callback destroy-notify)))

(export 'object-set-data-full)

;;; ----------------------------------------------------------------------------
;;; g_object_steal_data                                     not exported
;;; ----------------------------------------------------------------------------

(cffi:defcfun ("g_object_steal_data" object-steal-data) :pointer
 #+liber-documentation
 "@version{#2022-12-30}
  @argument[object]{a @class{g:object} instance containing the associations}
  @argument[key]{a string with the name of the key}
  @return{The data as a pointer if found, or @code{nil} if no such data exists.}
  @begin{short}
    Remove a specified datum from the data associations of the object, without
    invoking the destroy handler of the association.
  @end{short}
  @see-class{g:object}
  @see-function{g:object-data}
  @see-function{g:object-set-data-full}"
  (object object)
  (key :string))

;;;-----------------------------------------------------------------------------
;;; g_object_dup_data ()
;;;
;;; gpointer g_object_dup_data (GObject *object,
;;;                             const gchar *key,
;;;                             GDuplicateFunc dup_func,
;;;                             gpointer user_data);
;;;
;;; This is a variant of g_object_get_data() which returns a 'duplicate' of the
;;; value. dup_func defines the meaning of 'duplicate' in this context, it could
;;; e.g. take a reference on a ref-counted object.
;;;
;;; If the key is not set on the object then dup_func will be called with a NULL
;;; argument.
;;;
;;; Note that dup_func is called while user data of object is locked.
;;;
;;; This function can be useful to avoid races when multiple threads are using
;;; object data on the same key on the same object.
;;;
;;; object :
;;;     the GObject to store user data on
;;;
;;; key :
;;;     a string, naming the user data pointer
;;;
;;; dup_func :
;;;     function to dup the value. [allow-none]
;;;
;;; user_data :
;;;     passed as user_data to dup_func. [allow-none]
;;;
;;; Returns :
;;;     the result of calling dup_func on the value associated with key on
;;;     object, or NULL if not set. If dup_func is NULL, the value is returned
;;;     unmodified.
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_object_replace_data ()
;;;
;;; gboolean g_object_replace_data (GObject *object,
;;;                                 const gchar *key,
;;;                                 gpointer oldval,
;;;                                 gpointer newval,
;;;                                 GDestroyNotify destroy,
;;;                                 GDestroyNotify *old_destroy);
;;;
;;; Compares the user data for the key key on object with oldval, and if they
;;; are the same, replaces oldval with newval.
;;;
;;; This is like a typical atomic compare-and-exchange operation, for user data
;;; on an object.
;;;
;;; If the previous value was replaced then ownership of the old value (oldval)
;;; is passed to the caller, including the registred destroy notify for it
;;; (passed out in old_destroy). Its up to the caller to free this as he wishes,
;;; which may or may not include using old_destroy as sometimes replacement
;;; should not destroy the object in the normal way.
;;;
;;; Return: TRUE if the existing value for key was replaced by newval, FALSE
;;; otherwise.
;;;
;;; object :
;;;     the GObject to store user data on
;;;
;;; key :
;;;     a string, naming the user data pointer
;;;
;;; oldval :
;;;     the old value to compare against. [allow-none]
;;;
;;; newval :
;;;     the new value. [allow-none]
;;;
;;; destroy :
;;;     a destroy notify for the new value. [allow-none]
;;;
;;; old_destroy :
;;;     destroy notify for the existing value. [allow-none]
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_object_get_qdata ()
;;;
;;; gpointer g_object_get_qdata (GObject *object, GQuark quark);
;;;
;;; This function gets back user data pointers stored via g_object_set_qdata().
;;;
;;; object :
;;;     The GObject to get a stored user data pointer from
;;;
;;; quark :
;;;     A GQuark, naming the user data pointer
;;;
;;; Returns :
;;;     The user data pointer set, or NULL.
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_object_set_qdata ()
;;;
;;; void g_object_set_qdata (GObject *object, GQuark quark, gpointer data);
;;;
;;; This sets an opaque, named pointer on an object. The name is specified
;;; through a GQuark (retrived e.g. via g_quark_from_static_string()), and the
;;; pointer can be gotten back from the object with g_object_get_qdata() until
;;; the object is finalized. Setting a previously set user data pointer,
;;; overrides (frees) the old pointer set, using NULL as pointer essentially
;;; removes the data stored.
;;;
;;; object :
;;;     The GObject to set store a user data pointer
;;;
;;; quark :
;;;     A GQuark, naming the user data pointer
;;;
;;; data :
;;;     An opaque user data pointer
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_object_set_qdata_full ()
;;;
;;; void g_object_set_qdata_full (GObject *object,
;;;                               GQuark quark,
;;;                               gpointer data,
;;;                               GDestroyNotify destroy);
;;;
;;; This function works like g_object_set_qdata(), but in addition, a
;;; void (*destroy) (gpointer) function may be specified which is called with
;;; data as argument when the object is finalized, or the data is being
;;; overwritten by a call to g_object_set_qdata() with the same quark.
;;;
;;; object :
;;;     The GObject to set store a user data pointer
;;;
;;; quark :
;;;     A GQuark, naming the user data pointer
;;;
;;; data :
;;;     An opaque user data pointer
;;;
;;; destroy :
;;;     Function to invoke with data as argument, when data needs to be freed
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_object_steal_qdata ()
;;;
;;; gpointer g_object_steal_qdata (GObject *object, GQuark quark);
;;;
;;; This function gets back user data pointers stored via g_object_set_qdata()
;;; and removes the data from object without invoking its destroy() function (if
;;; any was set). Usually, calling this function is only required to update user
;;; data pointers with a destroy notifier, for example:
;;;
;;;   void
;;;   object_add_to_user_list (GObject     *object,
;;;                            const gchar *new_string)
;;;   {
;;;     // the quark, naming the object data
;;;     GQuark quark_string_list = g_quark_from_static_string("my-string-list");
;;;     // retrive the old string list
;;;     GList *list = g_object_steal_qdata (object, quark_string_list);
;;;
;;;     // prepend new string
;;;     list = g_list_prepend (list, g_strdup (new_string));
;;;     // this changed 'list', so we need to set it again
;;;     g_object_set_qdata_full (object, quark_string_list, list,
;;;                              free_string_list);
;;;   }
;;;   static void
;;;   free_string_list (gpointer data)
;;;   {
;;;     GList *node, *list = data;
;;;
;;;     for (node = list; node; node = node->next)
;;;       g_free (node->data);
;;;     g_list_free (list);
;;;   }
;;;
;;; Using g_object_get_qdata() in the above example, instead of
;;; g_object_steal_qdata() would have left the destroy function set, and thus
;;; the partial string list would have been freed upon
;;; g_object_set_qdata_full().
;;;
;;; object :
;;;     The GObject to get a stored user data pointer from
;;;
;;; quark :
;;;     A GQuark, naming the user data pointer
;;;
;;; Returns :
;;;     The user data pointer set, or NULL.
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_object_dup_qdata ()
;;;
;;; gpointer g_object_dup_qdata (GObject *object,
;;;                              GQuark quark,
;;;                              GDuplicateFunc dup_func,
;;;                              gpointer user_data);
;;;
;;; This is a variant of g_object_get_qdata() which returns a 'duplicate' of the
;;; value. dup_func defines the meaning of 'duplicate' in this context, it could
;;; e.g. take a reference on a ref-counted object.
;;;
;;; If the quark is not set on the object then dup_func will be called with a
;;; NULL argument.
;;;
;;; Note that dup_func is called while user data of object is locked.
;;;
;;; This function can be useful to avoid races when multiple threads are using
;;; object data on the same key on the same object.
;;;
;;; object :
;;;     the GObject to store user data on
;;;
;;; quark :
;;;     a GQuark, naming the user data pointer
;;;
;;; dup_func :
;;;     function to dup the value. [allow-none]
;;;
;;; user_data :
;;;     passed as user_data to dup_func. [allow-none]
;;;
;;; Returns :
;;;     the result of calling dup_func on the value associated with quark on
;;;     object, or NULL if not set. If dup_func is NULL, the value is returned
;;;     unmodified.
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_object_replace_qdata ()
;;;
;;; gboolean g_object_replace_qdata (GObject *object,
;;;                                  GQuark quark,
;;;                                  gpointer oldval,
;;;                                  gpointer newval,
;;;                                  GDestroyNotify destroy,
;;;                                  GDestroyNotify *old_destroy);
;;;
;;; Compares the user data for the key quark on object with oldval, and if they
;;; are the same, replaces oldval with newval.
;;;
;;; This is like a typical atomic compare-and-exchange operation, for user data
;;; on an object.
;;;
;;; If the previous value was replaced then ownership of the old value (oldval)
;;; is passed to the caller, including the registred destroy notify for it
;;; (passed out in old_destroy). Its up to the caller to free this as he wishes,
;;; which may or may not include using old_destroy as sometimes replacement
;;; should not destroy the object in the normal way.
;;;
;;; Return: TRUE if the existing value for quark was replaced by newval, FALSE
;;; otherwise.
;;;
;;; object :
;;;     the GObject to store user data on
;;;
;;; quark :
;;;     a GQuark, naming the user data pointer
;;;
;;; oldval :
;;;     the old value to compare against. [allow-none]
;;;
;;; newval :
;;;     the new value. [allow-none]
;;;
;;; destroy :
;;;     a destroy notify for the new value. [allow-none]
;;;
;;; old_destroy :
;;;     destroy notify for the existing value. [allow-none]
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_object_set_property
;;; g_object_get_property
;;; ----------------------------------------------------------------------------

(cffi:defcfun ("g_object_set_property" %object-set-property) :void
  (object object)
  (name :string)
  (value (:pointer (:struct value))))

(defun (setf object-property) (value object name &optional gtype)
  (unless gtype
    (setf gtype
          (class-property-type (type-from-instance object)
                               name
                               :assert-writable t)))
  (cffi:with-foreign-object (new-value '(:struct value))
    (unwind-protect
      (progn
        (set-g-value new-value value gtype :zero-gvalue t)
        (%object-set-property object name new-value))
      (value-unset new-value)))
  value)

(cffi:defcfun ("g_object_get_property" %object-get-property) :void
  (object object)
  (name :string)
  (value (:pointer (:struct value))))

(defun object-property (object name &optional gtype)
 #+liber-documentation
 "@version{2023-7-27}
  @syntax[]{(g:object-property object name gtype) => value}
  @syntax[]{(setf (g:object-property object name gtype) value)}
  @argument[object]{a @class{g:object} instance}
  @argument[name]{a string with the name of the property}
  @argument[gtype]{an optional @class{g:type-t} type ID of the property}
  @argument[value]{a value for the property}
  @short{Accessor of the property of an object.}
  @begin[Example]{dictionary}
    Setting and retrieving the
    @slot[gtk:settings]{gtk-application-prefer-dark-theme} setting.
    @begin{pre}
(defvar settings (gtk:settings-default))
=> SETTINGS
(setf (g:object-property settings \"gtk-application-prefer-dark-theme\") t)
=> T
(g:object-property settings \"gtk-application-prefer-dark-theme\")
=> T
    @end{pre}
  @end{dictionary}
  @see-class{g:object}
  @see-class{g:type-t}"
  (restart-case
    (unless gtype
      (setf gtype
            (class-property-type (type-from-instance object)
                                 name
                                 :assert-readable t)))
    (return-nil () (return-from object-property nil)))
  (cffi:with-foreign-object (value '(:struct value))
    (unwind-protect
      (progn
        (value-init value gtype)
        (%object-get-property object name value)
        (parse-g-value value))
      (value-unset value))))

(export 'object-property)

;;; ----------------------------------------------------------------------------
;;; g_object_new_valist ()
;;;
;;; GObject * g_object_new_valist (GType object_type,
;;;                                const gchar *first_property_name,
;;;                                va_list var_args);
;;;
;;; Creates a new instance of a GObject subtype and sets its properties.
;;;
;;; Construction parameters (see G_PARAM_CONSTRUCT, G_PARAM_CONSTRUCT_ONLY)
;;; which are not explicitly specified are set to their default values.
;;;
;;; object_type :
;;;     the type id of the GObject subtype to instantiate
;;;
;;; first_property_name :
;;;     the name of the first property
;;;
;;; var_args :
;;;     the value of the first property, followed optionally by more name/value
;;;     pairs, followed by NULL
;;;
;;; Returns :
;;;     a new instance of object_type
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_object_set_valist ()
;;;
;;; void g_object_set_valist (GObject *object,
;;;                           const gchar *first_property_name,
;;;                           va_list var_args);
;;;
;;; Sets properties on an object.
;;;
;;; object :
;;;     a GObject
;;;
;;; first_property_name :
;;;     name of the first property to set
;;;
;;; var_args :
;;;     value for the first property, followed optionally by more name/value
;;;     pairs, followed by NULL
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_object_get_valist ()
;;;
;;; void g_object_get_valist (GObject *object,
;;;                           const gchar *first_property_name,
;;;                           va_list var_args);
;;;
;;; Gets properties of an object.
;;;
;;; In general, a copy is made of the property contents and the caller is
;;; responsible for freeing the memory in the appropriate manner for the type,
;;; for instance by calling g_free() or g_object_unref().
;;;
;;; See g_object_get().
;;;
;;; object :
;;;     a GObject
;;;
;;; first_property_name :
;;;     name of the first property to get
;;;
;;; var_args :
;;;     return location for the first property, followed optionally by more
;;;     name/return location pairs, followed by NULL
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_object_watch_closure ()
;;;
;;; void g_object_watch_closure (GObject *object, GClosure *closure);
;;;
;;; This function essentially limits the life time of the closure to the life
;;; time of the object. That is, when the object is finalized, the closure is
;;; invalidated by calling g_closure_invalidate() on it, in order to prevent
;;; invocations of the closure with a finalized (nonexisting) object. Also,
;;; g_object_ref() and g_object_unref() are added as marshal guards to the
;;; closure, to ensure that an extra reference count is held on object during
;;; invocation of the closure. Usually, this function will be called on closures
;;; that use this object as closure data.
;;;
;;; object :
;;;     GObject restricting lifetime of closure
;;;
;;; closure :
;;;     GClosure to watch
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_object_run_dispose ()
;;;
;;; void g_object_run_dispose (GObject *object);
;;;
;;; Releases all references to other objects. This can be used to break
;;; reference cycles.
;;;
;;; This functions should only be called from object system implementations.
;;;
;;; object :
;;;     a GObject
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; G_OBJECT_WARN_INVALID_PROPERTY_ID()
;;;
;;; #define G_OBJECT_WARN_INVALID_PROPERTY_ID(object, property_id, pspec)
;;;
;;; This macro should be used to emit a standard warning about unexpected
;;; properties in set_property() and get_property() implementations.
;;;
;;; object :
;;;     the GObject on which set_property() or get_property() was called
;;;
;;; property_id :
;;;     the numeric id of the property
;;;
;;; pspec :
;;;     the GParamSpec of the property
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; GWeakRef
;;;
;;; typedef struct {
;;; } GWeakRef;
;;;
;;; A structure containing a weak reference to a GObject. It can either be empty
;;; (i.e. point to NULL), or point to an object for as long as at least one
;;; "strong" reference to that object exists. Before the object's
;;; GObjectClass.dispose method is called, every GWeakRef associated with
;;; becomes empty (i.e. points to NULL).
;;;
;;; Like GValue, GWeakRef can be statically allocated, stack- or heap-allocated,
;;; or embedded in larger structures.
;;;
;;; Unlike g_object_weak_ref() and g_object_add_weak_pointer(), this weak
;;; reference is thread-safe: converting a weak pointer to a reference is atomic
;;; with respect to invalidation of weak pointers to destroyed objects.
;;;
;;; If the object's GObjectClass.dispose method results in additional references
;;; to the object being held, any GWeakRefs taken before it was disposed will
;;; continue to point to NULL. If GWeakRefs are taken after the object is
;;; disposed and re-referenced, they will continue to point to it until its
;;; refcount goes back to zero, at which point they too will be invalidated.
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_weak_ref_init ()
;;;
;;; void g_weak_ref_init (GWeakRef *weak_ref, gpointer object);
;;;
;;; Initialise a non-statically-allocated GWeakRef.
;;;
;;; This function also calls g_weak_ref_set() with object on the
;;; freshly-initialised weak reference.
;;;
;;; This function should always be matched with a call to g_weak_ref_clear(). It
;;; is not necessary to use this function for a GWeakRef in static storage
;;; because it will already be properly initialised. Just use g_weak_ref_set()
;;; directly.
;;;
;;; weak_ref :
;;;     uninitialized or empty location for a weak reference
;;;
;;; object :
;;;     a GObject or NULL
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_weak_ref_clear ()
;;;
;;; void g_weak_ref_clear (GWeakRef *weak_ref);
;;;
;;; Frees resources associated with a non-statically-allocated GWeakRef. After
;;; this call, the GWeakRef is left in an undefined state.
;;;
;;; You should only call this on a GWeakRef that previously had
;;; g_weak_ref_init() called on it.
;;;
;;; weak_ref :
;;;     location of a weak reference, which may be empty
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_weak_ref_get ()
;;;
;;; gpointer g_weak_ref_get (GWeakRef *weak_ref);
;;;
;;; If weak_ref is not empty, atomically acquire a strong reference to the
;;; object it points to, and return that reference.
;;;
;;; This function is needed because of the potential race between taking the
;;; pointer value and g_object_ref() on it, if the object was losing its last
;;; reference at the same time in a different thread.
;;;
;;; The caller should release the resulting reference in the usual way, by using
;;; g_object_unref().
;;;
;;; weak_ref :
;;;     location of a weak reference to a GObject
;;;
;;; Returns :
;;;     the object pointed to by weak_ref, or NULL if it was empty
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_weak_ref_set ()
;;;
;;; void g_weak_ref_set (GWeakRef *weak_ref, gpointer object);
;;;
;;; Change the object to which weak_ref points, or set it to NULL.
;;;
;;; You must own a strong reference on object while calling this function.
;;;
;;; weak_ref :
;;;     location for a weak reference
;;;
;;; object :
;;;     a GObject or NULL
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_assert_finalize_object ()
;;;
;;; void
;;; g_assert_finalize_object (GObject *object);
;;;
;;; Assert that object is non-NULL, then release one reference to it with
;;; g_object_unref() and assert that it has been finalized (i.e. that there are
;;; no more references).
;;;
;;; If assertions are disabled via G_DISABLE_ASSERT, this macro just calls
;;; g_object_unref() without any further checks.
;;;
;;; This macro should only be used in regression tests.
;;;
;;; object :
;;;     an object.
;;;
;;; Since 2.62
;;; ----------------------------------------------------------------------------

;;; --- End of file gobject.base.lisp ------------------------------------------
