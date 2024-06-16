(in-package :glib-test)

(def-suite gio-action :in gio-suite)
(in-suite gio-action)

(defvar *verbose-gio-action* nil)

;;; --- Types and Values -------------------------------------------------------

;;;     GAction

(test g-action-interface
  ;; Check type
  (is-true (g:type-is-interface "GAction"))
  ;; Check registered symbol
  (is (eq 'g:action
          (glib:symbol-for-gtype "GAction")))
  ;; Check interface properties.
  (is (equal '("enabled" "name" "parameter-type" "state" "state-type")
             (list-interface-properties "GAction")))
  ;; Check signals
  (is (equal '()
             (list-signals "GAction")))
  ;; Check interface definition
  (is (equal '(GOBJECT:DEFINE-G-INTERFACE "GAction" G-ACTION
                                  (:EXPORT T
                                   :TYPE-INITIALIZER "g_action_get_type")
                                  (ENABLED G-ACTION-ENABLED
                                   "enabled" "gboolean" T NIL)
                                  (NAME G-ACTION-NAME
                                   "name" "gchararray" T NIL)
                                  (PARAMETER-TYPE G-ACTION-PARAMETER-TYPE
                                   "parameter-type" "GVariantType" T NIL)
                                  (STATE G-ACTION-STATE
                                   "state" "GVariant" T NIL)
                                  (STATE-TYPE G-ACTION-STATE-TYPE
                                   "state-type" "GVariantType" T NIL))
             (gobject:get-g-type-definition "GAction"))))

;;; --- Properties and Accessors -----------------------------------------------

;;;     action-enabled

(test g-action-enabled
  (let ((action (g:simple-action-new "simple" nil)))
    ;; Default value is true
    (is-true (g:action-enabled action))
    ;; Property enabled is writeable for g:simple-action
    (setf (g:action-enabled action) nil)
    (is-false (g:action-enabled action))))

;;;     action-name

(test g-action-name
  (let ((action (g:simple-action-new "simple" nil)))
    (is (string= "simple" (g:action-name action)))
    ;; TODO: Property name is not writeable, Lisp signals no error
;    (signals (error) (setf (g:action-name action) "new"))
))

;;;     action-parameter-type

(test g-action-parameter-type.1
  ;; Initialize parameter-type with nil
  (let ((action (g:simple-action-new "simple" nil)))
    (is-false (g:action-parameter-type action))))

(test g-action-parameter-type.2
  ;; Initialize parameter-type with type boolean
  (let ((action (g:simple-action-new "simple" (g:variant-type-new "b"))))
    (is (eq 'g:variant-type (type-of (g:action-parameter-type action))))
    (is (string= "b"
                 (g:variant-type-dup-string
                     (g:action-parameter-type action))))))

(test g-action-parameter-type.3
  ;; Initialize parameter-type with type boolean as string
  (let ((action (g:simple-action-new "simple" "b")))
    (is (eq 'g:variant-type (type-of (g:action-parameter-type action))))
    (is (string= "b"
                 (g:variant-type-dup-string
                     (g:action-parameter-type action))))))

;;;     action-state

(test g-action-state.1
  ;; It is an error to pass nil for the initialisation of state
  (signals (error) (g:simple-action-new-stateful "stateful" nil nil))
  ;; Initialize state with an integer
  (let ((action (g:simple-action-new-stateful "stateful"
                                              nil
                                              (g:variant-new-int32 123))))
    (is (= 123 (g:variant-int32 (g:action-state action))))
    (setf (g:action-state action) (g:variant-new-int32 321))
    (is (= 321 (g:variant-int32 (g:action-state action))))
    ;; TODO: It is an error to pass a wrong type, but no Lisp error
;    (signals (error) (setf (g:action-state action) (g:variant-new-int64 123)))
  ))

(test g-action-state.2
  (let ((action (g:simple-action-new "simple" nil)))
    (is (cffi:null-pointer-p (g:action-state action)))))

;;;     action-state-type

(test g-action-state-type.1
  (let ((action (g:simple-action-new-stateful "stateful"
                                              nil
                                              (g:variant-new-int32 123))))
    (is (eq 'g:variant-type (type-of (g:action-state-type action))))
    (is (string= "i" (g:variant-type-dup-string (g:action-state-type action))))
    (is (= 123 (g:variant-int32 (g:action-state action))))))

(test g-action-state-type.2
  (let ((action (g:simple-action-new-stateful "stateful"
                                              nil
                                              (g:variant-new-string "test"))))
    (is (eq 'g:variant-type (type-of (g:action-state-type action))))
    (is (string= "s" (g:variant-type-dup-string (g:action-state-type action))))
    (is (string= "test" (g:variant-string (g:action-state action))))))

;;; --- Functions --------------------------------------------------------------

;;;     g_action_name_is_valid

(test g-action-name-is-valid
  (is-true (g:action-name-is-valid "simple"))
  (is-true (g:action-name-is-valid "simple.1"))
  (is-false (g:action-name-is-valid "simple:test"))
  (is-false (g:action-name-is-valid "simple#test"))
  (signals (error) (g:action-name-is-valid nil)))

;;;     g_action_get_state_hint

;; TODO: Example for usage of this function

;;;     g_action_change_state
;;;     g_action_activate

(test g-action-change-state/activate
  (let ((param nil)
        (action (g:simple-action-new-stateful "simple"
                                              (g:variant-type-new "i")
                                              (g:variant-new-string "text"))))
    ;; Connect available signals
    (g:signal-connect action "activate"
        (lambda (action parameter)
          (setf param (g:variant-int32 parameter))
          (when *verbose-gio-action*
            (format t "~%")
            (format t "~&GAction signal : 'activate'~%")
            (format t "~&        action : ~A~%" action)
            (format t "~&          name : ~A~%" (g:action-name action))
            (format t "~&     parameter : ~A~%" (g:variant-int32 parameter)))))
    (g:signal-connect action "change-state"
        (lambda (action value)
          (setf (g:simple-action-state action) value)
          (when *verbose-gio-action*
            (format t "~%")
            (format t "~&GAction signal : 'change-state'~%")
            (format t "~&        action : ~A~%" action)
            (format t "~&          name : ~A~%" (g:action-name action))
            (format t "~&         value : ~A~%" (g:variant-string value)))))
    ;; action-change-state
    (is (string= "text" (g:variant-string (g:action-state action))))
    (g:action-change-state action (g:variant-new-string "new"))
    (is (string= "new" (g:variant-string (g:action-state action))))
    ;; action-activate
    (g:action-activate action (g:variant-new-int32 123))
    (is (= 123 param))
    (g:action-activate action (g:variant-new-int32 321))
    (is (= 321 param))))

;;;     g_action_parse_detailed_name

(test g-action-parse-detaild-name
  (is-true (g:action-parse-detailed-name "test"))
  (is-true (g:action-parse-detailed-name "test(123)"))
  (is-true (g:action-parse-detailed-name "app.action::target")))

;;;     g_action_print_detailed_name

(test g-action-print-detaild-name
  (is (string= "test(12)"
               (g:action-print-detailed-name "test" (g:variant-new-int32 12)))))

;;; 2024-5-14
