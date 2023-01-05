(in-package :glib-test)

(def-suite gobject-signals :in gobject-suite)
(in-suite gobject-signals)

(defvar *verbose-gobject-signals* t)

;;; --- Types and Values -------------------------------------------------------

;;;     GSignalInvocationHint
;;;     GSignalCMarshaller
;;;     GSignalCVaMarshaller
;;;     GSignalFlags
;;;     GSignalMatchType
;;;     GSignalQuery
;;;     GConnectFlags

;;;     G_SIGNAL_TYPE_STATIC_SCOPE
;;;     G_SIGNAL_MATCH_MASK
;;;     G_SIGNAL_FLAGS_MASK

;;; --- Functions --------------------------------------------------------------

;;;     g_signal_new
;;;     g_signal_newv
;;;     g_signal_new_valist
;;;     g_signal_set_va_marshaller

;;;     g-signal-query

(test signal-query
  (let* ((signal-id (g:signal-lookup "activate" "GSimpleAction"))
         (query (g:signal-query signal-id)))
      (is (= signal-id (g:signal-query-signal-id query)))
      (is (string= "activate" (g:signal-query-signal-name query)))
      (is (string= "GSimpleAction"
                   (g:type-name (g:signal-query-owner-type query))))
      (is (equal '(:must-collect :run-last)
                 (sort (g:signal-query-signal-flags query) #'string-lessp)))
      (is (string= "void" (g:type-name (g:signal-query-return-type query))))
      (is (equal '("GVariant")
                 (mapcar #'g:type-name (g:signal-query-param-types query))))
      (is-false (g:signal-query-signal-detail query))))

;;;     g_signal_lookup

(test signal-lookup
  (is (integerp (g:signal-lookup "activate" "GSimpleAction"))))

;;;     g_signal_name

(test signal-name
  (is (string= "activate"
               (g:signal-name (g:signal-lookup "activate" "GSimpleAction"))))
  (is (string= "change-state"
               (g:signal-name (g:signal-lookup "change-state" "GSimpleAction")))))

;;;     g_signal_list_ids

(test signal-list-ids
  (is (equal '()
             (mapcar #'g:signal-name (g:signal-list-ids "gboolean"))))
  (is (equal '()
             (sort (mapcar #'g:signal-name (g:signal-list-ids "GAction"))
                   #'string<)))
  (is (equal '("activate" "change-state")
             (sort (mapcar #'g:signal-name (g:signal-list-ids "GSimpleAction"))
                   #'string<)))
  ;; FIXME: We do not get the list of signals.
  (is (equal '("activate" "command-line" "handle-local-options" "name-lost"
               "open" "shutdown" "startup")
             (sort (mapcar #'g:signal-name (g:signal-list-ids "GApplication"))
                   #'string<))))

;;;     g_signal_emit

#+nil
(test g-signal-emit.1
  (let* ((message nil)
         (button (make-instance 'gtk:button))
         ;; Connect a signal handler
         (handler-id (g:signal-connect button "clicked"
                       (lambda (widget)
                         (declare (ignore widget))
                         (when *verbose-gobject-signals*
                           (format t "~&Signal 'clicked' for button.~%"))
                         (setf message "Signal 'clicked' for button")
                         t))))
    ;; The signal handler writes a message in the variable MESSAGE.
    ;; We emit the signal and check the value of MESSAGE.
    (is-true (integerp handler-id))
    (is-false (setf message nil))
    (is-false (g-signal-emit button "clicked"))
    (is (string= "Signal 'clicked' for button" message))
    (is-false (g-signal-handler-disconnect button handler-id))))

#+nil
(test g-signal-emit.2
  (let* ((message nil)
         (button (make-instance 'gtk:button))
         ;; Connect a signal handler
         (handler-id (g:signal-connect button "notify::can-default"
                       (lambda (widget pspec)
                         (declare (ignore widget))
                         (when *verbose-gobject-signals*
                           (format t "~&Signal 'notify::can-default' for button.~%"))
                         (setf message "Signal 'notify::can-default' for button")
                         (is (g-is-param-spec pspec))
                         (is (eq (gtype "GParamBoolean") (g-param-spec-type pspec)))
                         (is (eq (gtype "gboolean")
                                 (g-param-spec-value-type pspec)))
                         (is (string= "myBoolean" (g:param-spec-name pspec)))
                         (is (string= "GParamBoolean"
                                      (g-param-spec-type-name pspec)))
                         (is-true (g-param-spec-default-value pspec))
                         t))))
    ;; The signal handler writes a message in the variable MESSAGE.
    ;; We emit the signal and check the value of MESSAGE.
    (is-true (integerp handler-id))
    (is-false (setf message nil))
    (is-false (g-signal-emit button "notify::can-default"
                             (g:param-spec-boolean "myBoolean"
                                                   "myBool"
                                                   "Doku"
                                                   t
                                                   '(:readable :writable))))
    (is (string= "Signal 'notify::can-default' for button" message))
    (is-false (g-signal-handler-disconnect button handler-id))))

;; This test does not emit the signal, but sets the property "can-default".

#+nil
(test g-signal-emit.3
  (let* ((message nil)
         (button (make-instance 'gtk:button))
         ;; Connect a signal handler
         (handler-id (g:signal-connect button "notify::can-default"
                       (lambda (widget pspec)
                         (declare (ignore widget))
                         (when *verbose-gobject-signals*
                           (format t "~&Signal 'notify::can-default' for button.~%"))
                         (setf message "Signal 'notify::can-default' for button")
                         (is (g-is-param-spec pspec))
                         (is (eq (gtype "GParamBoolean")
                                 (g-param-spec-type pspec)))
                         (is (eq (gtype "gboolean")
                                 (g-param-spec-value-type pspec)))
                         (is (string= "can-default" (g:param-spec-name pspec)))
                         (is (string= "GParamBoolean"
                                      (g-param-spec-type-name pspec)))
                         (is-true (g-param-spec-default-value pspec))
                         t))))
    ;; The signal handler writes a message in the variable MESSAGE.
    ;; We emit the signal and check the value of MESSAGE.
    (is-true (integerp handler-id))
    (is-false (setf message nil))
    (is-true (setf (gtk-widget-can-default button) t))
    (is (string= "Signal 'notify::can-default' for button" message))
    (is-false (g-signal-handler-disconnect button handler-id))))

;;;     g_signal_emit_by_name
;;;     g_signal_emitv
;;;     g_signal_emit_valist
;;;     g_signal_connect
;;;     g_signal_connect_after
;;;     g_signal_connect_swapped
;;;     g_signal_connect_object

;;;     g_signal_connect_data
;;;     g_signal_connect_closure
;;;     g_signal_connect_closure_by_id

;;;     g-signal-handler-block
;;;     g-signal-handler-unblock

#+nil
(test g-signal-handler-block
  (let* ((button (make-instance 'gtk:button))
         (signal-id (g-signal-lookup "clicked" "GtkButton"))
         (handler-id (g:signal-connect button "clicked"
                       (lambda (widget)
                         (declare (ignore widget))
                         t))))
    ;; Block the handler
    (g-signal-handler-block button handler-id)
    (is-false (g-signal-has-handler-pending button signal-id (cffi:null-pointer) nil))
    (is-true (g-signal-has-handler-pending button signal-id (cffi:null-pointer) t))
    ;; Unblock the handler
    (g-signal-handler-unblock button handler-id)
    (is-true (g-signal-has-handler-pending button signal-id (cffi:null-pointer) nil))
    (is-true (g-signal-has-handler-pending button signal-id (cffi:null-pointer) t))))

;;;     g-signal-handler-disconnect

#+nil
(test g-signal-handler-disconnect
  (let* ((button (make-instance 'gtk:button))
         (handler-id (g:signal-connect button "clicked"
                       (lambda (widget)
                         (declare (ignore widget))
                         t))))
    (is-true (g-signal-handler-is-connected button handler-id))
    (is-false (g-signal-handler-disconnect button handler-id))
    ;; FIXME: The expected value is false.
    (is-true (g-signal-handler-is-connected button handler-id))))

;;;     g-signal-handler-find

#+nil
(test g-signal-handler-find
  (let* ((button (make-instance 'gtk:button))
         (signal-id (g-signal-lookup "clicked" "GtkButton"))
         (handler-id (g:signal-connect button "clicked"
                       (lambda (widget)
                         (declare (ignore widget))
                         t))))
    (is (= handler-id (g-signal-handler-find button signal-id)))))

;;;     g_signal_handlers_block_matched
;;;     g_signal_handlers_unblock_matched
;;;     g_signal_handlers_disconnect_matched

;;;     g-signal-handler-is-connected

#+nil
(test g-signal-handler-is-connected
  (let* ((button (make-instance 'gtk:button))
;         (signal-id (g-signal-lookup "clicked" "GtkButton"))
         ;; Connect a signal handler
         (handler-id (g:signal-connect button "clicked"
                       (lambda (widget)
                         (declare (ignore widget))
                         t))))
    (is-true (g-signal-handler-is-connected button handler-id))))

;;;     g_signal_handlers_block_by_func
;;;     g_signal_handlers_unblock_by_func
;;;     g_signal_handlers_disconnect_by_func
;;;     g_signal_handlers_disconnect_by_data

;;;     g-signal-has-handler-pending

#+nil
(test g-signal-has-handler-pending
  (let* ((button (make-instance 'gtk:button))
         (signal-id (g-signal-lookup "clicked" "GtkButton"))
         (handler-id (g:signal-connect button "clicked"
                       (lambda (widget)
                         (declare (ignore widget))
                         t))))
    (is (integerp handler-id))
    ;; We have a signal handler for the signal "clicked"
    (is-true (g-signal-has-handler-pending button signal-id (cffi:null-pointer) t))
    (is-true (g-signal-has-handler-pending button signal-id (cffi:null-pointer) nil))
    ;; We have no signal handler for the signal "pressed"
    (is-false (g-signal-has-handler-pending button
                                            (g-signal-lookup "pressed" "GtkButton")
                                            (cffi:null-pointer)
                                            t))
    (is-false (g-signal-has-handler-pending button
                                            (g-signal-lookup "pressed" "GtkButton")
                                            (cffi:null-pointer)
                                            nil))))

;;;     g_signal_stop_emission
;;;     g_signal_stop_emission_by_name
;;;     g_signal_override_class_closure
;;;     g_signal_chain_from_overridden
;;;     g_signal_new_class_handler
;;;     g_signal_override_class_handler
;;;     g_signal_chain_from_overridden_handler
;;;     g_signal_add_emission_hook
;;;     g_signal_remove_emission_hook
;;;     g_signal_is_valid_name
;;;     g_signal_parse_name
;;;     g_signal_get_invocation_hint
;;;     g_signal_type_cclosure_new
;;;     g_signal_accumulator_first_wins
;;;     g_signal_accumulator_true_handled
;;;     g_clear_signal_handler

;;; --- 2023-1-2 ---------------------------------------------------------------
