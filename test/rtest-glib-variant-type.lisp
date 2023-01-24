(in-package :glib-test)

(def-suite glib-variant-type :in glib-suite)
(in-suite glib-variant-type)

(defvar *verbose-glib-variant-type* t)

(defparameter vtypes
              (list "b" "y" "n" "q"  "i" "u" "x" "t" "h" "d" "s" "o" "g" "v"
                    "*" "?" "m*" "a*" "r" "()"  "{?*}" "a{?*}" "as" "ao" "ay"
                    "aay" "a(sv)"))

;;;     GVariantType

(test variant-type-struct
  ;; Type check
  (is (g:type-is-a (g:gtype "GVariantType") +g-type-boxed+))
  ;; Check the type initializer
  (is (eq (g:gtype "GVariantType")
          (g:gtype (cffi:foreign-funcall "g_variant_type_get_gtype" :size)))))

;;;     G_VARIANT_TYPE_BOOLEAN
;;;     G_VARIANT_TYPE_BYTE
;;;     G_VARIANT_TYPE_INT16
;;;     G_VARIANT_TYPE_UINT16
;;;     G_VARIANT_TYPE_INT32
;;;     G_VARIANT_TYPE_UINT32
;;;     G_VARIANT_TYPE_INT64
;;;     G_VARIANT_TYPE_UINT64
;;;     G_VARIANT_TYPE_HANDLE
;;;     G_VARIANT_TYPE_DOUBLE
;;;     G_VARIANT_TYPE_STRING
;;;     G_VARIANT_TYPE_OBJECT_PATH
;;;     G_VARIANT_TYPE_SIGNATURE
;;;     G_VARIANT_TYPE_VARIANT
;;;     G_VARIANT_TYPE_ANY
;;;     G_VARIANT_TYPE_BASIC
;;;     G_VARIANT_TYPE_MAYBE
;;;     G_VARIANT_TYPE_ARRAY
;;;     G_VARIANT_TYPE_TUPLE
;;;     G_VARIANT_TYPE_UNIT
;;;     G_VARIANT_TYPE_DICT_ENTRY
;;;     G_VARIANT_TYPE_DICTIONARY
;;;     G_VARIANT_TYPE_STRING_ARRAY
;;;     G_VARIANT_TYPE_OBJECT_PATH_ARRAY
;;;     G_VARIANT_TYPE_BYTESTRING
;;;     G_VARIANT_TYPE_BYTESTRING_ARRAY
;;;     G_VARIANT_TYPE_VARDICT

;;;     G_VARIANT_TYPE

;;;     g_variant_type_free

;;;     g_variant_type_copy

(test variant-type-copy
  (when *verbose-glib-variant-type*
    (format t "~%")
    (trace tg:finalize)
    (trace cffi:translate-from-foreign)
    (trace cffi:translate-to-foreign)
    (trace g:variant-type-copy))

  (let* ((variant1 (g:variant-type-new "b"))
         (variant2 (g:variant-type-copy variant1)))

    (is-false variant1)
    (is-false (gobject::boxed-opaque-pointer variant1))
    (is-false variant2)
    (is-false (gobject::boxed-opaque-pointer variant2))
  )

  (when *verbose-glib-variant-type*
    (untrace tg:finalize)
    (untrace cffi:translate-from-foreign)
    (untrace cffi:translate-to-foreign)
    (untrace g:variant-type-copy)))


;;;     g_variant_type_new

(test variant-type-new.1

  (when *verbose-glib-variant-type*
    (format t "~%")
    (trace tg:finalize)
    (trace cffi:translate-from-foreign)
    (trace cffi:translate-to-foreign)
    (trace g:variant-type-new))

  (let ((variant (g:variant-type-new "b")))
    (is (typep variant 'g:variant-type))
    (is (cffi:pointerp (gobject::boxed-opaque-pointer variant)))
  )

  (when *verbose-glib-variant-type*
    (untrace tg:finalize)
    (untrace cffi:translate-from-foreign)
    (untrace cffi:translate-to-foreign)
    (untrace g:variant-type-new)))


(test variant-type-new.2
  (is (every (lambda (x) (typep x 'g:variant-type))
             (mapcar #'g:variant-type-new vtypes))))

;;;     g_variant_type_string_is_valid

(test variant-type-string-is-valid.1
  (is-true (g:variant-type-string-is-valid "b")))

(test variant-type-string-is-valid.2
  (is-true (g:variant-type-string-is-valid "aaaaai")))

(test variant-type-string-is-valid.3
  (is-true (g:variant-type-string-is-valid "(ui(nq((y)))s)")))

(test variant-type-string-is-valid.4
  (is-true (g:variant-type-string-is-valid "a(aa(ui)(qna{ya(yd)}))")))

;;;   g_variant_type_string_scan                           not implemented
;;;   g_variant_type_get_string_length                     not exported
;;;   g_variant_type_peek_string                           not exported

;;;   g_variant_type_dup_string

(test variant-type-dup-string.1
  (is (string= "b" (g:variant-type-dup-string (g:variant-type-new "b")))))

(test variant-type-dup-string.2
  (is (equal vtypes
             (mapcar #'g:variant-type-dup-string
                     (mapcar #'g:variant-type-new vtypes)))))

;;;   g_variant_type_is_definite

(test variant-type-is-definite
  (is-true (g:variant-type-is-definite (g:variant-type-new "b")))
  (is-false (g:variant-type-is-definite (g:variant-type-new "*")))
  (is-false (g:variant-type-is-definite (g:variant-type-new "?")))
  (is-false (g:variant-type-is-definite (g:variant-type-new "r"))))

;;;   g_variant_type_is_container

(test variant-type-is-container
  (is-false (g:variant-type-is-container (g:variant-type-new "b")))
  (is-true (g:variant-type-is-container (g:variant-type-new "a*"))))

;;;   g_variant_type_is_basic

(test variant-type-is-basic
  (is-true (g:variant-type-is-basic (g:variant-type-new "b"))))

;;;   g_variant_type_is_maybe

(test variant-type-is-maybe
  (is-false (g:variant-type-is-maybe (g:variant-type-new "b"))))

;;;   g_variant_type_is_array

(test variant-type-is-array
  (is-false (g:variant-type-is-array (g:variant-type-new "b"))))

;;;   g_variant_type_is_tuple

(test variant-type-is-tuple
  (is-false (g:variant-type-is-tuple (g:variant-type-new "b"))))

;;;   g_variant_type_is_dict_entry

(test variant-type-is-dict-entry
  (is-false (g:variant-type-is-dict-entry (g:variant-type-new "b"))))

;;;   g_variant_type_is_variant

(test variant-type-is-variant
  (is-false (g:variant-type-is-variant (g:variant-type-new "b"))))

;;;   g_variant_type_hash

(test variant-type-hash
  (is-true (integerp (g:variant-type-hash (g:variant-type-new "b")))))

;;;   g_variant_type_equal

(test variant-type-equal
  (let ((bool1 (g:variant-type-new "b"))
        (bool2 (g:variant-type-new "b"))
        (int16 (g:variant-type-new "n")))
    (is-true (g:variant-type-equal bool1 bool2))
    (is-false (g:variant-type-equal bool1 int16))))

;;;   g_variant_type_is_subtype_of

(test variant-type-is-subtype-of
  (let ((bool (g:variant-type-new "b"))
        (any  (g:variant-type-new "*")))
    (is-true (g:variant-type-is-subtype-of bool bool))
    (is-true (g:variant-type-is-subtype-of bool any))
    (is-false (g:variant-type-is-subtype-of any bool))))

;;;   g_variant_type_new_maybe

(test variant-type-new-maybe
  (let ((bool (g:variant-type-new "b")))
    (is-true (g:variant-type-new-maybe bool))
    (is-true (g:variant-type-is-maybe (g:variant-type-new-maybe bool)))
    (is (string= "mb"
                 (g:variant-type-dup-string (g:variant-type-new-maybe bool))))))

;;;   g_variant_type_new_array

(test variant-type-new-arry
  (let ((bool (g:variant-type-new "b")))
    (is-true (g:variant-type-new-array bool))
    (is-true (g:variant-type-is-array (g:variant-type-new-array bool)))
    (is (string= "ab"
                 (g:variant-type-dup-string (g:variant-type-new-array bool))))))

;;;   g_variant_type_new_tuple

(test variant-type-new-tuple.1
  (let ((bool (g:variant-type-new "b")))
    (is-true (g:variant-type-new-tuple bool bool bool))
    (is-true (g:variant-type-is-tuple (g:variant-type-new-tuple bool bool bool)))
    (is (string= "(bbb)"
                 (g:variant-type-dup-string
                     (g:variant-type-new-tuple bool bool bool))))))

(test variant-type-new-tuple.2
  (let ((str (g:variant-type-new "s")))
    (is-true (g:variant-type-new-tuple str str str))
    (is-true (g:variant-type-is-tuple (g:variant-type-new-tuple str str str)))
    (is (string= "(sss)"
                 (g:variant-type-dup-string
                     (g:variant-type-new-tuple str str str))))))

(test variant-type-new-tuple.3
  (let ((str (g:variant-type-new "s"))
        (bool (g:variant-type-new "b")))
    (is-true (g:variant-type-new-tuple str bool str))
    (is-true (g:variant-type-is-tuple (g:variant-type-new-tuple str bool str)))
    (is (string= "(sbs)"
                 (g:variant-type-dup-string
                     (g:variant-type-new-tuple str bool str))))))

;;;     g_variant_type_new_dict_entry

(test variant-type-new-dict-entry
  (let ((bool (g:variant-type-new "b"))
        (int16 (g:variant-type-new "n")))
    (is-true (g:variant-type-new-dict-entry int16 bool))
    (is-true (g:variant-type-is-dict-entry
                 (g:variant-type-new-dict-entry int16 bool)))
    (is (string= "{nb}"
                 (g:variant-type-dup-string
                     (g:variant-type-new-dict-entry int16 bool))))))

;;;     g_variant_type_element

(test variant-type-element
  (let ((bool (g:variant-type-new "b")))
    (is-true (g:variant-type-element (g:variant-type-new-array bool)))
    (is (string= "b"
                 (g:variant-type-dup-string
                     (g:variant-type-element (g:variant-type-new-array bool)))))))

;;;     g_variant_type_n_items

(test variant-type-n-items
  (let ((bool (g:variant-type-new "b")))
    (is (= 3
           (g:variant-type-n-items (g:variant-type-new-tuple bool bool bool))))))

;;;   g_variant_type_first

(test variant-type-first
  (let* ((bool (g:variant-type-new "b"))
         (int16 (g:variant-type-new "n"))
         (tuple (g:variant-type-new-tuple bool int16 bool bool int16)))
    (is (string= "b"
                 (g:variant-type-dup-string (g:variant-type-first tuple))))))

;;;   g_variant_type_next

(test variant-type-next
  (let* ((bool (g:variant-type-new "b"))
         (int16 (g:variant-type-new "n"))
         (tuple (g:variant-type-new-tuple bool int16 bool bool int16))
         (iter (g:variant-type-first tuple)))
    (is (equal "b" (g:variant-type-dup-string iter)))
    (setf iter (g:variant-type-next iter))
    (is (equal "n" (g:variant-type-dup-string iter)))
    (setf iter (g:variant-type-next iter))
    (is (equal "b" (g:variant-type-dup-string iter)))
    (setf iter (g:variant-type-next iter))
    (is (equal "b" (g:variant-type-dup-string iter)))
    (setf iter (g:variant-type-next iter))
    (is (equal "n" (g:variant-type-dup-string iter)))
    (setf iter (g:variant-type-next iter))
    ;; At last we get a NULL-POINTER
;    (is-true (cffi:null-pointer-p iter))
    ))

;;;   g_variant_type_key
;;;   g_variant_type_value

(test variant-type-key
  (let* ((key-type (g:variant-type-new "n"))
         (value-type (g:variant-type-new "b"))
         (dict (g:variant-type-new-dict-entry key-type value-type)))
    (is (string= "n" (g:variant-type-dup-string (g:variant-type-key dict))))
    (is (string= "b" (g:variant-type-dup-string (g:variant-type-value dict))))))

;;; 2021-7-31
