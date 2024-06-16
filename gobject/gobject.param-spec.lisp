;;; ----------------------------------------------------------------------------
;;; gobject.param-spec.lisp
;;;
;;; The documentation of this file is taken from the GObject Reference Manual
;;; Version 2.76 and modified to document the Lisp binding to the GObject
;;; library. See <http://www.gtk.org>. The API documentation of the Lisp
;;; binding is available from <http://www.crategus.com/books/cl-cffi-gtk4/>.
;;;
;;; Copyright (C) 2011 - 2023 Dieter Kaiser
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
;;; GParamSpec
;;;
;;;     Metadata for parameter specifications
;;;
;;; Types and Values
;;;
;;;     GParamSpec
;;;     GParamSpecClass
;;;     GParamFlags
;;;
;;;     G_PARAM_STATIC_STRINGS
;;;     G_PARAM_MASK
;;;     G_PARAM_USER_SHIFT
;;;
;;;     GParamSpecTypeInfo
;;;     GParamSpecPool
;;;
;;; Functions
;;;
;;;     G_TYPE_IS_PARAM
;;;     G_PARAM_SPEC
;;;     G_IS_PARAM_SPEC
;;;     G_PARAM_SPEC_CLASS
;;;     G_IS_PARAM_SPEC_CLASS
;;;     G_PARAM_SPEC_GET_CLASS
;;;     G_PARAM_SPEC_TYPE
;;;     G_PARAM_SPEC_TYPE_NAME
;;;     G_PARAM_SPEC_VALUE_TYPE
;;;
;;;     g_param_spec_ref
;;;     g_param_spec_unref
;;;     g_param_spec_sink
;;;     g_param_spec_ref_sink
;;;     g_param_spec_get_default_value
;;;     g_param_value_set_default
;;;     g_param_value_defaults
;;;     g_param_value_validate
;;;     g_param_value_convert
;;;     g_param_values_cmp
;;;     g_param_spec_is_valid_name
;;;     g_param_spec_get_name
;;;     g_param_spec_get_name_quark
;;;     g_param_spec_get_nick
;;;     g_param_spec_get_blurb
;;;     g_param_spec_get_qdata
;;;     g_param_spec_set_qdata
;;;     g_param_spec_set_qdata_full
;;;     g_param_spec_steal_qdata
;;;     g_param_spec_get_redirect_target
;;;     g_param_spec_internal
;;;     g_param_type_register_static
;;;
;;;     g_param_spec_pool_new
;;;     g_param_spec_pool_insert
;;;     g_param_spec_pool_remove
;;;     g_param_spec_pool_lookup
;;;     g_param_spec_pool_list
;;;     g_param_spec_pool_list_owned
;;; ----------------------------------------------------------------------------

(in-package :gobject)

;;; ----------------------------------------------------------------------------
;;; enum GParamFlags
;;; ----------------------------------------------------------------------------

(cffi:defbitfield param-flags
  (:readable #.(ash 1 0))
  (:writable #.(ash 1 1))
  (:construct #.(ash 1 2))
  (:construct-only #.(ash 1 3))
  (:lax-validation #.(ash 1 4))
  (:static-name #.(ash 1 5))
  (:static-nick #.(ash 1 6))
  (:static-blurb #.(ash 1 7))
  (:deprecated #.(ash 1 31)))

#+liber-documentation
(setf (liber:alias-for-symbol 'param-flags)
      "Bitfield"
      (liber:symbol-documentation 'param-flags)
 "@version{#2022-12-29}
  @begin{short}
    Through the @sym{g:param-flags} flag values, certain aspects of parameters
    can be configured.
  @end{short}
  @begin{pre}
(cffi:defbitfield param-flags
  (:readable #.(ash 1 0))
  (:writable #.(ash 1 1))
  (:construct #.(ash 1 2))
  (:construct-only #.(ash 1 3))
  (:lax-validation #.(ash 1 4))
  (:static-name #.(ash 1 5))
  (:static-nick #.(ash 1 6))
  (:static-blurb #.(ash 1 7))
  (:deprecated #.(ash 1 31)))
  @end{pre}
  @begin[code]{table}
    @entry[:readable]{The parameter is readable.}
    @entry[:writable]{The parameter is writable.}
    @entry[:construct]{The parameter will be set upon object construction.}
    @entry[:construct-only]{The parameter will only be set upon object
      construction.}
    @entry[:lax-validation]{Upon parameter conversion (see
      @code{g_param_value_convert()}) strict validation is not required.}
    @entry[:static-name]{The string used as name when constructing the parameter
      is guaranteed to remain valid and unmodified for the lifetime of the
      parameter.}
    @entry[:static-nick]{The string used as nick when constructing the parameter
      is guaranteed to remain valid and unmmodified for the lifetime of the
      parameter.}
    @entry[:static-blurb]{The string used as blurb when constructing the
      parameter is guaranteed to remain valid and unmodified for the lifetime
      of the parameter.}
    @entry[:deprecated]{The parameter is deprecated and will be removed in a
      future version. A warning will be generated if it is used while running
      with @code{G_ENABLE_DIAGNOSTIC=1}.}
  @end{table}
  @see-symbol{g:param-spec}")

(export 'param-flags)

;;; ----------------------------------------------------------------------------
;;; struct GParamSpec
;;; ----------------------------------------------------------------------------

(cffi:defcstruct param-spec
  (:type-instance (:pointer (:struct type-instance)))
  (:name (:string :free-from-foreign nil :free-to-foreign nil))
  (:flags param-flags)
  (:value-type type-t)
  (:owner-type type-t))

#+liber-documentation
(setf (liber:alias-for-symbol 'param-spec)
      "CStruct"
      (liber:symbol-documentation 'param-spec)
 "@version{#2022-12-29}
  @begin{short}
    The @sym{g:param-spec} structure is an object structure that encapsulates
    the metadata required to specify parameters, such as e.g. @class{g:object}
    properties.
  @end{short}

  Parameter names need to start with a letter (a-z or A-Z). Subsequent
  characters can be letters, numbers or a '-'. All other characters are
  replaced by a '-' during construction. The result of this replacement is
  called the canonical name of the parameter.
  @begin{pre}
(cffi:defcstruct param-spec
  (:type-instance (:pointer (:struct type-instance)))
  (:name (:string :free-from-foreign nil :free-to-foreign nil))
  (:flags param-flags)
  (:value-type type-t)
  (:owner-type type-t))
  @end{pre}
  @begin[code]{table}
    @entry[:type-instance]{Private @symbol{g:type-instance} portion.}
    @entry[:name]{Name of this parameter: always an interned string.}
    @entry[:flags]{The @symbol{g:param-flags} flags for this parameter.}
    @entry[:value-type]{The @symbol{g:value} type for this parameter.}
    @entry[:owner-type]{The @class{g:type-t} that uses this parameter.}
  @end{table}
  @see-symbol{g:type-instance}
  @see-symbol{g:param-flags}
  @see-symbol{g:value}
  @see-class{g:type-t}")

(export 'param-spec)

;;; ----------------------------------------------------------------------------

;; Corresponding Lisp structure describing a property of a GObject class.

;; TODO: %PARAM-SPEC is the structure to access a GParamSpec from the Lisp side.
;; This should be exported and not the implementatin PARAM-SPEC which
;; corresponds to the C side

(defstruct %param-spec
  name
  type
  readable
  writable
  constructor
  constructor-only
  owner-type)

(defmethod print-object ((instance %param-spec) stream)
  (if *print-readably*
      (call-next-method)
      (print-unreadable-object (instance stream)
        (format stream
                "PROPERTY ~A ~A . ~A (flags:~@[~* readable~]~@[~* writable~]~@[~* constructor~]~@[~* constructor-only~])"
                (glib:gtype-name (%param-spec-type instance))
                (%param-spec-owner-type instance)
                (%param-spec-name instance)
                (%param-spec-readable instance)
                (%param-spec-writable instance)
                (%param-spec-constructor instance)
                (%param-spec-constructor-only instance)))))

;; Transform a value of the C type GParamSpec to Lisp type %param-spec

(defun parse-g-param-spec (param)
  (assert (not (cffi:null-pointer-p param))
          nil
          "PARSE-G-PARAM-SPEC: argument is a NULL-pointer")
  (let ((flags (cffi:foreign-slot-value param '(:struct param-spec) :flags)))
    (make-%param-spec
      :name (cffi:foreign-slot-value param '(:struct param-spec) :name)
      :type (cffi:foreign-slot-value param '(:struct param-spec) :value-type)
      :readable (not (null (member :readable flags)))
      :writable (not (null (member :writable flags)))
      :constructor (not (null (member :construct flags)))
      :constructor-only (not (null (member :construct-only flags)))
      :owner-type (cffi:foreign-slot-value param
                                           '(:struct param-spec) :owner-type))))

;;; ----------------------------------------------------------------------------
;;; struct GParamSpecClass                                 not exported
;;; ----------------------------------------------------------------------------

(cffi:defcstruct param-spec-class
  (:type-class (:pointer (:struct type-class)))
  (:value-type type-t)
  (:finalize :pointer)
  (:value-set-default :pointer)
  (:value-validate :pointer)
  (:values-cmp :pointer))

#+liber-documentation
(setf (liber:alias-for-symbol 'param-spec-class)
      "CStruct"
      (liber:symbol-documentation 'param-spec-class)
 "@version{#2013-2-7}
  @begin{short}
    The class structure for the @symbol{g:param-spec} type.
  @end{short}
  Normally, @symbol{g:param-spec} classes are filled by the
  @fun{g:param-type-register-static} function.
  @begin{pre}
(cffi:defcstruct param-spec-class
  (:type-class (:pointer (:struct type-class)))
  (:value-type type-t)
  (:finalize :pointer)
  (:value-set-default :pointer)
  (:value-validate :pointer)
  (:values-cmp :pointer))
  @end{pre}
  @begin[code]{table}
    @entry[:type-class]{the parent class}
    @entry[:value-type]{the GValue type for this parameter}
    @entry[:finalize]{The instance finalization function (optional), should
      chain up to the finalize method of the parent class.}
    @entry[:value-set-default]{Resets a value to the default value for this type
      (recommended, the default is @fun{value-reset}), see
      @fun{g:param-value-set-default}.}
    @entry[:value-validate]{Ensures that the contents of value comply with the
      specifications set out by this type (optional), see
      @fun{g:param-value-validate}.}
    @entry[:value-cmp]{Compares value1 with value2 according to this type
      (recommended, the default is @code{memcmp()}), see
      @fun{g:param-values-cmp}.}
  @end{table}")

;;; ----------------------------------------------------------------------------
;;; G_TYPE_IS_PARAM
;;; ----------------------------------------------------------------------------

(defun type-is-param (gtype)
 #+liber-documentation
 "@version{2024-6-10}
  @argument[gtype]{a @class{g:type-t} type ID}
  @begin{short}
    Checks whether @arg{gtype} \"is a\" @code{\"GParam\"} type.
  @end{short}
  @see-symbol{g:param-spec}
  @see-class{g:type-t}"
  (eq (type-fundamental gtype) (glib:gtype "GParam")))

(export 'type-is-param)

;;; ----------------------------------------------------------------------------
;;; G_PARAM_SPEC()
;;;
;;; #define G_PARAM_SPEC(pspec)
;;;         (G_TYPE_CHECK_INSTANCE_CAST ((pspec), G_TYPE_PARAM, GParamSpec))
;;;
;;; Casts a derived GParamSpec object (e.g. of type GParamSpecInt) into a
;;; GParamSpec object.
;;;
;;; pspec :
;;;     a valid GParamSpec
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; G_IS_PARAM_SPEC
;;; ----------------------------------------------------------------------------

(defun is-param-spec (pspec)
 #+liber-documentation
 "@version{2024-6-10}
  @argument[pspec]{a @symbol{g:param-spec} instance}
  @begin{short}
    Checks whether @arg{pspec} \"is a\" valid @symbol{g:param-spec} instance
    of @code{\"GParam\"} type or derived.
  @end{short}
  @see-symbol{g:param-spec}"
  (type-is-param (type-from-instance pspec)))

(export 'is-param-spec)

;;; ----------------------------------------------------------------------------
;;; G_PARAM_SPEC_CLASS()
;;;
;;; #define G_PARAM_SPEC_CLASS(pclass)
;;;         (G_TYPE_CHECK_CLASS_CAST ((pclass), G_TYPE_PARAM, GParamSpecClass))
;;;
;;; Casts a derived GParamSpecClass structure into a GParamSpecClass structure.
;;;
;;; pclass :
;;;     a valid GParamSpecClass
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; G_IS_PARAM_SPEC_CLASS()
;;;
;;; #define G_IS_PARAM_SPEC_CLASS(pclass)
;;;         (G_TYPE_CHECK_CLASS_TYPE ((pclass), G_TYPE_PARAM))
;;;
;;; Checks whether pclass "is a" valid GParamSpecClass structure of type
;;; G_TYPE_PARAM or derived.
;;;
;;; pclass :
;;;     a GParamSpecClass
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; G_PARAM_SPEC_GET_CLASS()
;;;
;;; #define G_PARAM_SPEC_GET_CLASS(pspec)
;;;         (G_TYPE_INSTANCE_GET_CLASS ((pspec), G_TYPE_PARAM, GParamSpecClass))
;;;
;;; Retrieves the GParamSpecClass of a GParamSpec.
;;;
;;; pspec :
;;;     a valid GParamSpec
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; G_PARAM_SPEC_TYPE()
;;; ----------------------------------------------------------------------------

(defun param-spec-type (pspec)
 #+liber-documentation
 "@version{2022-12-29}
  @argument[pspec]{a valid @symbol{g:param-spec} instance}
  @short{Retrieves the @class{g:type-t} of this @arg{pspec}.}
  @see-symbol{g:param-spec}
  @see-class{g:type-t}"
  (type-from-instance pspec))

(export 'param-spec-type)

;;; ----------------------------------------------------------------------------
;;; G_PARAM_SPEC_TYPE_NAME()
;;; ----------------------------------------------------------------------------

(defun param-spec-type-name (pspec)
 #+liber-documentation
 "@version{2022-12-29}
  @argument[pspec]{a valid @symbol{g:param-spec} instance}
  @short{Retrieves the @class{g:type-t} name of @arg{pspec}.}
  @see-symbol{g:param-spec}
  @see-class{g:type-t}"
  (type-name (param-spec-type pspec)))

(export 'param-spec-type-name)

;;; ----------------------------------------------------------------------------
;;; G_PARAM_SPEC_VALUE_TYPE()
;;; ----------------------------------------------------------------------------

(defun param-spec-value-type (pspec)
 #+liber-documentation
 "@version{2022-12-29}
  @argument[pspec]{a valid @symbol{g:param-spec} instance}
  @short{Retrieves the @class{g:type-t} to initialize a @symbol{g:value} for
    this parameter.}
  @see-symbol{g:param-spec}
  @see-class{g:type-t}
  @see-symbol{g:value}"
  (cffi:foreign-slot-value pspec '(:struct param-spec) :value-type))

(export 'param-spec-value-type)

;;; ----------------------------------------------------------------------------
;;; G_PARAM_STATIC_STRINGS
;;;
;;; #define G_PARAM_STATIC_STRINGS
;;;         (G_PARAM_STATIC_NAME | G_PARAM_STATIC_NICK | G_PARAM_STATIC_BLURB)
;;;
;;; GParamFlags value alias for G_PARAM_STATIC_NAME | G_PARAM_STATIC_NICK |
;;; G_PARAM_STATIC_BLURB.
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; G_PARAM_MASK
;;;
;;; #define G_PARAM_MASK (0x000000ff)
;;;
;;; Mask containing the bits of GParamSpec.flags which are reserved for GLib.
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; G_PARAM_USER_SHIFT
;;;
;;; #define G_PARAM_USER_SHIFT (8)
;;;
;;; Minimum shift count to be used for user defined flags, to be stored in
;;; GParamSpec.flags. The maximum allowed is 30 + G_PARAM_USER_SHIFT.
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_param_spec_ref ()
;;;
;;; GParamSpec * g_param_spec_ref (GParamSpec *pspec);
;;;
;;; Increments the reference count of pspec.
;;;
;;; pspec :
;;;     a valid GParamSpec
;;;
;;; Returns :
;;;     the GParamSpec that was passed into this function
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_param_spec_unref ()                                  not exported
;;; ----------------------------------------------------------------------------

(cffi:defcfun ("g_param_spec_unref" %param-spec-unref) :void
 #+liber-documentation
 "@version{#2013-2-7}
  @argument[pspec]{a valid @symbol{g:param-spec}}
  @short{Decrements the reference count of a pspec.}"
  (pspec (:pointer (:struct param-spec))))

;;; ----------------------------------------------------------------------------
;;; g_param_spec_sink ()
;;;
;;; void g_param_spec_sink (GParamSpec *pspec);
;;;
;;; The initial reference count of a newly created GParamSpec is 1, even though
;;; no one has explicitly called g_param_spec_ref() on it yet. So the initial
;;; reference count is flagged as "floating", until someone calls
;;; g_param_spec_ref (pspec); g_param_spec_sink (pspec); in sequence on it,
;;; taking over the initial reference count (thus ending up with a pspec that
;;; has a reference count of 1 still, but is not flagged "floating" anymore).
;;;
;;; pspec :
;;;     a valid GParamSpec
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_param_spec_ref_sink ()                               not exported
;;; ----------------------------------------------------------------------------

(cffi:defcfun ("g_param_spec_ref_sink" %param-spec-ref-sink)
    (:pointer (:struct param-spec))
 #+liber-documentation
 "@version{#2013-2-7}
  @argument[pspec]{a valid @symbol{g:param-spec}}
  @return{the GParamSpec that was passed into this function}
  @short{Convenience function to ref and sink a GParamSpec.} @break{}"
  (pspec (:pointer (:struct param-spec))))

;;; ----------------------------------------------------------------------------
;;; g_param_spec_get_default_value () -> param-spec-default-value
;;; ----------------------------------------------------------------------------

(cffi:defcfun ("g_param_spec_get_default_value" param-spec-default-value)
    (:pointer (:struct value))
 #+liber-documentation
 "@version{2022-12-29}
  @argument[pspec]{a valid @symbol{g:param-spec} instance}
  @return{A pointer to a @symbol{g:value} instance.}
  @begin{short}
    Gets the default value of @arg{pspec} as a pointer to a @symbol{g:value}
    instance.
  @end{short}
  @see-symbol{g:param-spec}
  @see-symbol{g:value}"
  (pspec (:pointer (:struct param-spec))))

(export 'param-spec-default-value)

;;; ----------------------------------------------------------------------------
;;; g_param_value_set_default ()
;;; ----------------------------------------------------------------------------

(cffi:defcfun ("g_param_value_set_default" param-value-set-default) :void
 #+liber-documentation
 "@version{2022-12-29}
  @argument[pspec]{a valid @symbol{g:param-spec} instance}
  @argument[value]{a @symbol{g:value} instance of correct type for @arg{pspec}}
  @short{Sets @arg{value} to its default value as specified in @arg{pspec}.}
  @see-symbol{g:param-spec}
  @see-symbol{g:value}"
  (pspec (:pointer (:struct param-spec)))
  (value (:pointer (:struct value))))

(export 'param-value-set-default)

;;; ----------------------------------------------------------------------------
;;; g_param_value_defaults ()
;;; ----------------------------------------------------------------------------

(cffi:defcfun ("g_param_value_defaults" param-value-defaults) :boolean
 #+liber-documentation
 "@version{2022-12-29}
  @argument[pspec]{a valid @symbol{g:param-spec} instance}
  @argument[value]{a @symbol{g:value} instance of correct type for @arg{pspec}}
  @return{A boolean whether @arg{value} contains the canonical default for this
    @arg{pspec}.}
  @begin{short}
    Checks whether @arg{value} contains the default value as specified in
    @arg{pspec}.
  @end{short}
  @see-symbol{g:param-spec}
  @see-symbol{g:value}"
  (pspec (:pointer (:struct param-spec)))
  (value (:pointer (:struct value))))

(export 'param-value-defaults)

;;; ----------------------------------------------------------------------------
;;; g_param_value_validate ()
;;; ----------------------------------------------------------------------------

(cffi:defcfun ("g_param_value_validate" param-value-validate) :boolean
 #+liber-documentation
 "@version{2022-12-29}
  @argument[pspec]{a valid @symbol{g:param-spec} instance}
  @argument[value]{a @symbol{g:value} instance of correct type for @arg{pspec}}
  @return{A boolean whether modifying @arg{value} was necessary to ensure
    validity.}
  @begin{short}
    Ensures that the contents of @arg{value} comply with the specifications set
    out by @arg{pspec}.
  @end{short}

  For example, a @symbol{g:param-spec-int} might require that integers stored
  in @arg{value} may not be smaller than -42 and not be greater than +42. If
  @arg{value} contains an integer outside of this range, it is modified
  accordingly, so the resulting value will fit into the range -42 .. +42.
  @see-symbol{g:param-spec}
  @see-symbol{g:value}
  @see-symbol{g:param-spec-int}"
  (pspec (:pointer (:struct param-spec)))
  (value (:pointer (:struct value))))

(export 'param-value-validate)

;;; ----------------------------------------------------------------------------
;;; g_param_value_convert ()
;;;
;;; gboolean g_param_value_convert (GParamSpec *pspec,
;;;                                 const GValue *src_value,
;;;                                 GValue *dest_value,
;;;                                 gboolean strict_validation);
;;;
;;; Transforms src_value into dest_value if possible, and then validates
;;; dest_value, in order for it to conform to pspec. If strict_validation is
;;; TRUE this function will only succeed if the transformed dest_value complied
;;; to pspec without modifications.
;;;
;;; See also g_value_type_transformable(), g_value_transform() and
;;; g_param_value_validate().
;;;
;;; pspec :
;;;     a valid GParamSpec
;;;
;;; src_value :
;;;     souce GValue
;;;
;;; dest_value :
;;;     destination GValue of correct type for pspec
;;;
;;; strict_validation :
;;;     TRUE requires dest_value to conform to pspec without modifications
;;;
;;; Returns :
;;;     TRUE if transformation and validation were successful, FALSE otherwise
;;;     and dest_value is left untouched.
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_param_values_cmp ()                                  not exported
;;; ----------------------------------------------------------------------------

(cffi:defcfun ("g_param_values_cmp" %param-values-cmp) :int
 #+liber-documentation
 "@version{#2013-5-21}
  @argument[pspec]{a valid @symbol{g:param-spec}}
  @argument[value1]{a @symbol{value} of correct type for @arg{pspec}}
  @argument[value2]{a @symbol{value} of correct type for @arg{pspec}}
  @return{-1, 0 or +1, for a less than, equal to or greater than result}
  @begin{short}
    Compares @arg{value1} with @arg{value2} according to @arg{pspec}, and return
    -1, 0 or +1, if @arg{value1} is found to be less than, equal to or greater
    than @arg{value2}, respectively.
  @end{short}
  @see-symbol{g:param-spec}
  @see-symbol{g:value}"
  (pspec (:pointer (:struct param-spec)))
  (value1 (:pointer (:struct value)))
  (value2 (:pointer (:struct value))))

;;; ----------------------------------------------------------------------------
;;; g_param_spec_is_valid_name ()
;;;
;;; gboolean
;;; g_param_spec_is_valid_name (const gchar *name);
;;;
;;; Validate a property name for a GParamSpec. This can be useful for
;;; dynamically-generated properties which need to be validated at run-time
;;; before actually trying to create them.
;;;
;;; See canonical parameter names for details of the rules for valid names.
;;;
;;; name:
;;;     the canonical name of the property
;;;
;;; Returns:
;;;     TRUE if name is a valid property name, FALSE otherwise.
;;;
;;; Since 2.66
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_param_spec_get_name () -> param-spec-name
;;; ----------------------------------------------------------------------------

(cffi:defcfun ("g_param_spec_get_name" param-spec-name) :string
 #+liber-documentation
 "@version{2022-12-29}
  @argument[pspec]{a valid @symbol{g:param-spec} instance}
  @return{A string with the name of @arg{pspec}.}
  @begin{short}
    Gets the name of a @symbol{g:param-spec} instance.
  @end{short}
  @begin[Example]{dictionary}
    @begin{pre}
(mapcar #'g:param-spec-name
        (g:object-class-list-properties \"GtkApplication\"))
=> (\"application-id\" \"flags\" \"resource-base-path\" \"is-registered\"
    \"is-remote\" \"inactivity-timeout\" \"action-group\" \"is-busy\"
    \"register-session\" \"screensaver-active\" \"menubar\" \"active-window\")
    @end{pre}
  @end{dictionary}
  @see-symbol{g:param-spec}"
  (pspec (:pointer (:struct param-spec))))

(export 'param-spec-name)

;;; ----------------------------------------------------------------------------
;;; g_param_spec_get_name_quark ()
;;;
;;; GQuark
;;; g_param_spec_get_name_quark (GParamSpec *pspec);
;;;
;;; Gets the GQuark for the name.
;;;
;;; pspec:
;;;     a GParamSpec
;;;
;;; Returns:
;;;     the GQuark for pspec->name .
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_param_spec_get_nick () -> param-spec-nick
;;; ----------------------------------------------------------------------------

(cffi:defcfun ("g_param_spec_get_nick" param-spec-nick) :string
 #+liber-documentation
 "@version{2022-12-29}
  @argument[pspec]{a valid @symbol{g:param-spec} instance}
  @return{A string with the nickname of @arg{pspec}.}
  @short{Get the nickname of a @symbol{g:param-spec} instance.}
  @see-symbol{g:param-spec}"
  (pspec (:pointer (:struct param-spec))))

(export 'param-spec-nick)

;;; ----------------------------------------------------------------------------
;;; g_param_spec_get_blurb () -> param-spec-blurb
;;; ----------------------------------------------------------------------------

(cffi:defcfun ("g_param_spec_get_blurb" param-spec-blurb) :string
 #+liber-documentation
 "@version{2022-12-29}
  @argument[pspec]{a valid @symbol{g:param-spec} instance}
  @return{A string with the short description of @arg{pspec}.}
  @short{Gets the short description of a @symbol{g:param-spec} instance.}
  @see-symbol{g:param-spec}"
  (pspec (:pointer (:struct param-spec))))

(export 'param-spec-blurb)

;;; ----------------------------------------------------------------------------
;;; g_param_spec_get_qdata ()
;;;
;;; gpointer g_param_spec_get_qdata (GParamSpec *pspec, GQuark quark);
;;;
;;; Gets back user data pointers stored via g_param_spec_set_qdata().
;;;
;;; pspec :
;;;     a valid GParamSpec
;;;
;;; quark :
;;;     a GQuark, naming the user data pointer
;;;
;;; Returns :
;;;     the user data pointer set, or NULL
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_param_spec_set_qdata ()
;;;
;;; void g_param_spec_set_qdata (GParamSpec *pspec, GQuark quark, gpointer data)
;;;
;;; Sets an opaque, named pointer on a GParamSpec. The name is specified through
;;; a GQuark (retrieved e.g. via g_quark_from_static_string()), and the pointer
;;; can be gotten back from the pspec with g_param_spec_get_qdata(). Setting a
;;; previously set user data pointer, overrides (frees) the old pointer set,
;;; using NULL as pointer essentially removes the data stored.
;;;
;;; pspec :
;;;     the GParamSpec to set store a user data pointer
;;;
;;; quark :
;;;     a GQuark, naming the user data pointer
;;;
;;; data :
;;;     an opaque user data pointer
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_param_spec_set_qdata_full ()
;;;
;;; void g_param_spec_set_qdata_full (GParamSpec *pspec,
;;;                                   GQuark quark,
;;;                                   gpointer data,
;;;                                   GDestroyNotify destroy);
;;;
;;; This function works like g_param_spec_set_qdata(), but in addition, a void
;;; (*destroy) (gpointer) function may be specified which is called with data as
;;; argument when the pspec is finalized, or the data is being overwritten by a
;;; call to g_param_spec_set_qdata() with the same quark.
;;;
;;; pspec :
;;;     the GParamSpec to set store a user data pointer
;;;
;;; quark :
;;;     a GQuark, naming the user data pointer
;;;
;;; data :
;;;     an opaque user data pointer
;;;
;;; destroy :
;;;     function to invoke with data as argument, when data needs to be freed
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_param_spec_steal_qdata ()
;;;
;;; gpointer g_param_spec_steal_qdata (GParamSpec *pspec, GQuark quark);
;;;
;;; Gets back user data pointers stored via g_param_spec_set_qdata() and removes
;;; the data from pspec without invoking its destroy() function (if any was
;;; set). Usually, calling this function is only required to update user data
;;; pointers with a destroy notifier.
;;;
;;; pspec :
;;;     the GParamSpec to get a stored user data pointer from
;;;
;;; quark :
;;;     a GQuark, naming the user data pointer
;;;
;;; Returns :
;;;     the user data pointer set, or NULL
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_param_spec_get_redirect_target ()                    not exported
;;; ----------------------------------------------------------------------------

(cffi:defcfun ("g_param_spec_get_redirect_target"
               %param-spec-get-redirect-target) (:pointer (:struct param-spec))
 #+liber-documentation
 "@version{#2014-11-13}
  @argument[pspec]{a @symbol{g:param-spec} instance}
  @begin{return}
    paramspec to which requests on this paramspec should be redirected, or
    @code{nil} if none.
  @end{return}
  @begin{short}
    If the paramspec redirects operations to another paramspec, returns that
    paramspec.
  @end{short}
  Redirect is used typically for providing a new implementation of a property
  in a derived type while preserving all the properties from the parent type.
  Redirection is established by creating a property of type
  @code{GParamSpecOverride}. See the function
  @fun{object-class-override-property} for an example of the use of this
  capability.
  @see-symbol{g:param-spec}
  @see-function{g:object-class-override-property}"
  (pspec (:pointer (:struct param-spec))))

;;; ----------------------------------------------------------------------------
;;; g_param_spec_internal
;;; ----------------------------------------------------------------------------

(cffi:defcfun ("g_param_spec_internal" param-spec-internal) :pointer
 #+liber-documentation
 "@version{2024-6-10}
  @argument[param-type]{a @class{g:type-t} type ID for the property, must be
    derived from the @code{\"GParam\"} type}
  @argument[name]{a string with the canonical name of the property}
  @argument[nick]{a string with the nickname of the property}
  @argument[blurb]{a string with a short description of the property}
  @argument[flags]{a combination of flags of type @symbol{g:param-flags}}
  @return{The newly allocated @symbol{g:param-spec} instance.}
  @begin{short}
    Creates a new parameter specification instance.
  @end{short}
  A property name consists of segments consisting of ASCII letters and digits,
  separated by either the '-' or '_' character. The first character of a
  property name must be a letter. Names which violate these rules lead to
  undefined behaviour.

  When creating and looking up a @symbol{g:param-spec} instance, either
  separator can be used, but they cannot be mixed. Using '-' is considerably
  more efficient and in fact required when using property names as detail
  strings for signals.

  Beyond @arg{name}, @symbol{g:param-spec} instances have two more descriptive
  strings associated with them, @arg{nick}, which should be suitable for use as
  a label for the property in a property editor, and @arg{blurb}, which should
  be a somewhat longer description, suitable for e.g. a tooltip. @arg{nick} and
  @arg{blurb} should ideally be localized.
  @begin[Examples]{dictionary}
    @begin{pre}
(g:param-spec-internal \"GParamBoolean\" \"Boolean\" \"Bool\" \"Doku\" '(:readable :writable))
=> #.(SB-SYS:INT-SAP #X00933890)
(g:param-spec-type-name *)
=> \"GParamBoolean\"
    @end{pre}
  @end{dictionary}
  @see-symbol{g:param-spec}
  @see-symbol{g:param-flags}
  @see-class{g:type-t}"
  (param-type type-t)
  (name :string)
  (nick :string)
  (blurb :string)
  (flags param-flags))

(export 'param-spec-internal)

;;; ----------------------------------------------------------------------------
;;; struct GParamSpecTypeInfo
;;;
;;; struct GParamSpecTypeInfo {
;;;   /* type system portion */
;;;   guint16     instance_size;                              /* obligatory */
;;;   guint16     n_preallocs;                                /* optional */
;;;   void        (*instance_init)     (GParamSpec   *pspec); /* optional */
;;;
;;;   /* class portion */
;;;   GType       value_type;                                 /* obligatory */
;;;   void        (*finalize)          (GParamSpec   *pspec); /* optional */
;;;   void        (*value_set_default) (GParamSpec   *pspec,  /* recommended */
;;;                                     GValue       *value);
;;;   gboolean    (*value_validate)    (GParamSpec   *pspec,  /* optional */
;;;                                     GValue       *value);
;;;   gint        (*values_cmp)        (GParamSpec   *pspec,  /* recommended */
;;;                                     const GValue *value1,
;;;                                     const GValue *value2);
;;; };
;;;
;;; This structure is used to provide the type system with the information
;;; required to initialize and destruct (finalize) a parameter's class and
;;; instances thereof. The initialized structure is passed to the
;;; g_param_type_register_static() The type system will perform a deep copy
;;; of this structure, so its memory does not need to be persistent across
;;; invocation of g_param_type_register_static().
;;;
;;; guint16 instance_size;
;;;     Size of the instance (object) structure.
;;;
;;; guint16 n_preallocs;
;;;     Prior to GLib 2.10, it specified the number of pre-allocated (cached)
;;;     instances to reserve memory for (0 indicates no caching). Since
;;;     GLib 2.10, it is ignored, since instances are allocated with the slice
;;;     allocator now.
;;;
;;; instance_init ()
;;;     Location of the instance initialization function (optional).
;;;
;;; GType value_type;
;;;     The GType of values conforming to this GParamSpec
;;;
;;; finalize ()
;;;     The instance finalization function (optional).
;;;
;;; value_set_default ()
;;;     Resets a value to the default value for pspec (recommended, the default
;;;     is g_value_reset()), see g_param_value_set_default().
;;;
;;; value_validate ()
;;;     Ensures that the contents of value comply with the specifications set
;;;     out by pspec (optional), see g_param_value_validate().
;;;
;;; values_cmp ()
;;;     Compares value1 with value2 according to pspec (recommended, the
;;;     default is memcmp()), see g_param_values_cmp().
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_param_type_register_static ()
;;;
;;; GType g_param_type_register_static (const gchar *name,
;;;                                     const GParamSpecTypeInfo *pspec_info);
;;;
;;; Registers name as the name of a new static type derived from G_TYPE_PARAM.
;;; The type system uses the information contained in the GParamSpecTypeInfo
;;; structure pointed to by info to manage the GParamSpec type and its
;;; instances.
;;;
;;; name :
;;;     0-terminated string used as the name of the new GParamSpec type.
;;;
;;; pspec_info :
;;;     The GParamSpecTypeInfo for this GParamSpec type.
;;;
;;; Returns :
;;;     The new type identifier.
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; GParamSpecPool
;;;
;;; typedef struct _GParamSpecPool GParamSpecPool;
;;;
;;; A GParamSpecPool maintains a collection of GParamSpecs which can be quickly
;;; accessed by owner and name. The implementation of the GObject property
;;; system uses such a pool to store the GParamSpecs of the properties all
;;; object types.
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_param_spec_pool_new ()
;;;
;;; GParamSpecPool * g_param_spec_pool_new (gboolean type_prefixing);
;;;
;;; Creates a new GParamSpecPool.
;;;
;;; If type_prefixing is TRUE, lookups in the newly created pool will allow to
;;; specify the owner as a colon-separated prefix of the property name, like
;;; "GtkContainer:border-width". This feature is deprecated, so you should
;;; always set type_prefixing to FALSE.
;;;
;;; type_prefixing :
;;;     Whether the pool will support type-prefixed property names.
;;;
;;; Returns :
;;;     a newly allocated GParamSpecPool
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_param_spec_pool_insert ()
;;;
;;; void g_param_spec_pool_insert (GParamSpecPool *pool,
;;;                                GParamSpec *pspec,
;;;                                GType owner_type);
;;;
;;; Inserts a GParamSpec in the pool.
;;;
;;; pool :
;;;     a GParamSpecPool.
;;;
;;; pspec :
;;;     the GParamSpec to insert
;;;
;;; owner_type :
;;;     a GType identifying the owner of pspec
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_param_spec_pool_remove ()
;;;
;;; void g_param_spec_pool_remove (GParamSpecPool *pool, GParamSpec *pspec);
;;;
;;; Removes a GParamSpec from the pool.
;;;
;;; pool :
;;;     a GParamSpecPool
;;;
;;; pspec :
;;;     the GParamSpec to remove
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_param_spec_pool_lookup ()
;;;
;;; GParamSpec * g_param_spec_pool_lookup (GParamSpecPool *pool,
;;;                                        const gchar *param_name,
;;;                                        GType owner_type,
;;;                                        gboolean walk_ancestors);
;;;
;;; Looks up a GParamSpec in the pool.
;;;
;;; pool :
;;;     a GParamSpecPool
;;;
;;; param_name :
;;;     the name to look for
;;;
;;; owner_type :
;;;     the owner to look for
;;;
;;; walk_ancestors :
;;;     If TRUE, also try to find a GParamSpec with param_name owned by an
;;;     ancestor of owner_type.
;;;
;;; Returns :
;;;     The found GParamSpec, or NULL if no matching GParamSpec was found.
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_param_spec_pool_list ()
;;;
;;; GParamSpec ** g_param_spec_pool_list (GParamSpecPool *pool,
;;;                                       GType owner_type,
;;;                                       guint *n_pspecs_p);
;;;
;;; Gets an array of all GParamSpecs owned by owner_type in the pool.
;;;
;;; pool :
;;;     a GParamSpecPool
;;;
;;; owner_type :
;;;     the owner to look for
;;;
;;; n_pspecs_p :
;;;     return location for the length of the returned array
;;;
;;; Returns :
;;;     a newly allocated array containing pointers to all GParamSpecs owned by
;;;     owner_type in the pool
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_param_spec_pool_list_owned ()
;;;
;;; GList * g_param_spec_pool_list_owned (GParamSpecPool *pool,
;;;                                       GType owner_type);
;;;
;;; Gets an GList of all GParamSpecs owned by owner_type in the pool.
;;;
;;; pool :
;;;     a GParamSpecPool
;;;
;;; owner_type :
;;;     the owner to look for
;;;
;;; Returns :
;;;     a GList of all GParamSpecs owned by owner_type in the poolGParamSpecs
;;; ----------------------------------------------------------------------------

;;; --- End of file gobject.param-spec.lisp ------------------------------------
