(in-package :glib-test)

(def-suite gio-application :in gio-suite)
(in-suite gio-application)

(defvar *verbose-g-application* nil)

;;; --- Types and Values -------------------------------------------------------

;;;     GApplicationFlags

(test application-flags
  ;; Check the type
  (is (g:type-is-flags "GApplicationFlags"))
  ;; Check the registered symbol
  (is (eq 'g:application-flags
          (gobject:symbol-for-gtype "GApplicationFlags")))
  ;; Check the names
  (is (equal '("G_APPLICATION_FLAGS_NONE" "G_APPLICATION_IS_SERVICE"
               "G_APPLICATION_IS_LAUNCHER" "G_APPLICATION_HANDLES_OPEN"
               "G_APPLICATION_HANDLES_COMMAND_LINE"
               "G_APPLICATION_SEND_ENVIRONMENT" "G_APPLICATION_NON_UNIQUE"
               "G_APPLICATION_CAN_OVERRIDE_APP_ID"
               "G_APPLICATION_ALLOW_REPLACEMENT" "G_APPLICATION_REPLACE")
             (list-flags-item-name "GApplicationFlags")))
  ;; Check the values
  (is (equal '(0 1 2 4 8 16 32 64 128 256)
             (list-flags-item-value "GApplicationFlags")))
  ;; Check the nick names
  (is (equal '("flags-none" "is-service" "is-launcher" "handles-open"
               "handles-command-line" "send-environment" "non-unique"
               "can-override-app-id" "allow-replacement" "replace")
             (list-flags-item-nick "GApplicationFlags")))
  ;; Check the flags definition
  (is (equal '(DEFINE-G-FLAGS "GApplicationFlags"
                              G-APPLICATION-FLAGS
                              (:EXPORT T)
                              (:FLAGS-NONE 0)
                              (:IS-SERVICE 1)
                              (:IS-LAUNCHER 2)
                              (:HANDLES-OPEN 4)
                              (:HANDLES-COMMAND-LINE 8)
                              (:SEND-ENVIRONMENT 16)
                              (:NON-UNIQUE 32)
                              (:CAN-OVERRIDE-APP-ID 64)
                              (:ALLOW-REPLACEMENT 128)
                              (:REPLACE 256))
             (get-g-type-definition "GApplicationFlags"))))

;;;     GApplication

(test application-class
  ;; Type check
  (is (g:type-is-object "GApplication"))
  ;; Check the registered symbol
  (is (eq 'g:application
          (gobject:symbol-for-gtype "GApplication")))
  ;; Check the parent
  (is (eq (g:gtype "GObject") (g:type-parent "GApplication")))
  ;; Check the children
  (is (equal '()
             (list-children "GApplication")))
  ;; Check the interfaces
  (is (equal '("GActionGroup" "GActionMap")
             (list-interfaces "GApplication")))
  ;; Check the class properties
  (is (equal '("action-group" "application-id" "flags" "inactivity-timeout"
               "is-busy" "is-registered" "is-remote" "resource-base-path")
             (list-properties "GApplication")))
  (is (equal '("activate" "command-line" "handle-local-options" "name-lost"
               "open" "shutdown" "startup")
             (list-signals "GApplication")))
  ;; Check the class definition
  (is (equal '(DEFINE-G-OBJECT-CLASS "GApplication" G-APPLICATION
                       (:SUPERCLASS G-OBJECT :EXPORT T :INTERFACES
                        ("GActionGroup" "GActionMap"))
                       ((ACTION-GROUP G-APPLICATION-ACTION-GROUP "action-group"
                         "GActionGroup" NIL T)
                        (APPLICATION-ID G-APPLICATION-APPLICATION-ID
                         "application-id" "gchararray" T T)
                        (FLAGS G-APPLICATION-FLAGS "flags" "GApplicationFlags"
                         T T)
                        (INACTIVITY-TIMEOUT G-APPLICATION-INACTIVITY-TIMEOUT
                         "inactivity-timeout" "guint" T T)
                        (IS-BUSY G-APPLICATION-IS-BUSY "is-busy" "gboolean" T
                         NIL)
                        (IS-REGISTERED G-APPLICATION-IS-REGISTERED
                         "is-registered" "gboolean" T NIL)
                        (IS-REMOTE G-APPLICATION-IS-REMOTE "is-remote"
                         "gboolean" T NIL)
                        (RESOURCE-BASE-PATH G-APPLICATION-RESOURCE-BASE-PATH
                         "resource-base-path" "gchararray" T T)))
             (get-g-type-definition "GApplication"))))

;;; --- Properties and Accessors -----------------------------------------------

;;;     g_application_action_group

(test application-action-group
  (let ((app (make-instance 'g:application))
        (group (make-instance 'g:simple-action-group)))
    ;; action-group is not readable
    (signals (error) (g:application-action-group app))
    (is-true (setf (g:application-action-group app) group))))

;;;     g_application_application_id

(test application-application-id
  (let ((app (make-instance 'g:application)))
    (is-false (g:application-application-id app))
    (is-true (setf (g:application-application-id app) "com.crategus.app"))
    (is (string= "com.crategus.app" (g:application-application-id app)))))

;;;     g_application_flags

(test application-flags
  (let ((app (make-instance 'g:application)))
    (is-false (g:application-flags app))
    ;; a single flag
    (is-true (setf (g:application-flags app) :handles-open))
    (is (equal '(:handles-open) (g:application-flags app)))
    ;; the flag :none does not set a non-nil value !?
    (is-true (setf (g:application-flags app) :none))
    (is-false (g:application-flags app))
    ;; a list of flags
    (is-true (setf (g:application-flags app) '(:is-service :handles-open)))
    (is (equal '(:is-service :handles-open) (g:application-flags app)))))

;;;     g_applicaton_inactivity_timeout

(test application-inactivity-timeout
  (let ((app (make-instance 'g:application)))
    (is (= 0 (g:application-inactivity-timeout app)))
    (is (= 10000 (setf (g:application-inactivity-timeout app) 10000)))
    (is (= 10000 (g:application-inactivity-timeout app)))))

;;;     g_application_is_busy

(test application-is-busy
  (let ((app (make-instance 'g:application)))
    ;; Default value is nil
    (is-false (g:application-is-busy app))
    ;; is-busy is not writeable
    (signals (error) (setf (g:application-is-busy app) t))))

;;;     g_application_is_registered

(test application-is-registered
  (let ((app (make-instance 'g:application)))
    (is-false (g:application-is-registered app))
    ;; is-registered is not writeable
    (signals (error) (setf (g:application-is-registered app) t))))

;;;     g_application_is_remote

(test application-is-remote
  (let ((app (make-instance 'g:application)))
    ;; is-remote is not readable before registration
;   (is-false (g:application-is-remote app))
    ;; is-remote is not writeable
    (signals (error) (setf (g:application-is-remote app) t))))

;;;     g_application_resource_base_path

(test application-resource-base-path
  (let ((app (make-instance 'g:application)))
    (is-false (g:application-resource-base-path app))
    (is (string= "/test" (setf (g:application-resource-base-path app) "/test")))
    (is (string= "/test" (g:application-resource-base-path app)))))

;;; --- Signals ----------------------------------------------------------------

;;     activate
;;     command-line
;;     handle-local-options
;;     name-lost
;;     open
;;     shutdown
;;     startup

(defun example-application-open (&optional (argv nil))
  (let ((in-startup nil) (in-activate nil) (in-open nil) (in-shutdown nil))
    (let ((app (make-instance 'g:application
                              :application-id "com.crategus.application-open"
                              :inactivity-timeout 2000
                              :flags :handles-open)))

      ;; Signal handler "startup"
      (g:signal-connect app "startup"
                        (lambda (application)
                          (declare (ignore application))
                          (setf in-startup t)
                          (when *verbose-g-application*
                            (format t "The application is in startup.~%"))))

      ;; Signal handler "activate"
      (g:signal-connect app "activate"
                        (lambda (application)
                          (declare (ignore application))
                          (g:application-hold app)
                          (setf in-activate t)
                          (when *verbose-g-application*
                            (format t "The application is in activate.~%"))
                          ;; Note: when doing a longer-lasting action that
                          ;; returns to the main loop, you should use
                          ;; g-application-hold and g-application-release to
                          ;; keep the application alive until the action is
                          ;; completed.
                          (g:application-release app)))

      ;; Signal handler "open"
      (g:signal-connect app "open"
                        (lambda (application files n-files hint)
                          (declare (ignore application files n-files hint))
                          (setf in-open t)
                          (when *verbose-g-application*
                            (format t "The application is in open.~%"))
                          ;; TODO: The argument "files" is a C pointer to an
                          ;; array of GFiles. The conversion to a list of
                          ;; strings with the call
                          ;; (cffi:convert-from-foreign files 'g-strv)
                          ;; does not work. Search a better implementation to
                          ;; get a list of GFiles.
                        ))

      ;; Signal handler "shutdown"
      (g:signal-connect app "shutdown"
                        (lambda (application)
                          (declare (ignore application))
                          (setf in-shutdown t)
                          (when *verbose-g-application*
                            (format t "The application is in shutdown.~%"))))

      ;; Start the application
      (g:application-run app argv))
      ;; Return the results
      (list in-startup in-activate in-open in-shutdown)))

;; Error when running the complete testsuite
; G-APPLICATION-SIGNALS []:
;      Unexpected Error: #<TYPE-ERROR expected-type: SB-SYS:SYSTEM-AREA-POINTER
;                               datum: #<PANGO-TAB-ARRAY {10126E16E3}>>
;The value
;  #<PANGO-TAB-ARRAY {10126E16E3}>
;is not of type
;  SB-SYS:SYSTEM-AREA-POINTER
;when binding SB-ALIEN::VALUE..

#+nil
(test g-application-signals
  (is (equal '(t t nil t) (example-application-open)))
  (is (equal '(t nil t t) (example-application-open '("demo" "file1" "file2")))))

;;; --- Functions --------------------------------------------------------------

;;;     g_application_id_is_valid
;;;     g_application_new
;;;     g_application_get_dbus_connection
;;;     g_application_get_dbus_object_path
;;;     g_application_set_action_group                     deprecated
;;;     g_application_register
;;;     g_application_hold
;;;     g_application_release
;;;     g_application_quit
;;;     g_application_activate

;;;     g_application_open

;; TODO: This example gives an error:
;; GLib-GIO-CRITICAL **: 20:48:15.580: g_application_open:
;; assertion 'application->priv->is_registered' failed

#+nil
(test g-application-open
  (let* ((app (make-instance 'g-application
                             :flags :handles-open))
         (files (list "file1" "file2" "file3"))
         (n-files (length files))
         (hint "hint"))

    (g:signal-connect app "open"
        (lambda (application files n-files hint)
          (declare (ignore application hint))
          (format t "in OPEN signal handler~%")
          (dotimes (i n-files)
            (let ((file (mem-aref files '(g-object g-file) i)))
              (format t "~a~%" (g-file-path file))))))

    (with-foreign-object (files-ptr :pointer n-files)
      (loop for i from 0 below n-files
            for file in files
            for file-ptr = (g:object-pointer (g:file-new-for-path file))
            do (format t "  i : ~a  ~a  ~a~%" i file files)
               (setf (mem-aref files-ptr :pointer i) file-ptr))
      (gio::%g-application-open app files-ptr n-files hint)

)))

;;;     g_application_send_notification
;;;     g_application_withdraw_notification
;;;     g_application_run
;;;     g_application_add_main_option_entries
;;;     g_application_add_main_option
;;;     g_application_add_option_group
;;;     g_application_set_option_context_parameter_string
;;;     g_application_set_option_context_summary
;;;     g_application_set_option_context_description
;;;     g_application_set_default
;;;     g_application_get_default
;;;     g_application_mark_busy
;;;     g_application_unmark_busy
;;;     g_application_bind_busy_property
;;;     g_application_unbind_busy_property

;;; --- 2022-1-2 ---------------------------------------------------------------
