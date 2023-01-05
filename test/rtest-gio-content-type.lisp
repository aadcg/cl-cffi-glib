(in-package :glib-test)

(def-suite gio-content-type :in gio-suite)
(in-suite gio-content-type)

;;;     g_content_type_equals
;;;     g_content_type_is_a
;;;     g_content_type_is_mime_type
;;;     g_content_type_is_unknown

;;;     g_content_type_get_description

(test content-type-description
  (is (every #'stringp
             (mapcar #'g:content-type-description
                     (g:content-types-registered)))))

;;;   g_content_type_get_mime_type

(test content-type-mime-type
  (is (every #'stringp
             (mapcar #'g:content-type-mime-type
                     (g:content-types-registered)))))

;;;   g_content_type_get_icon

(test content-type-icon
  (is (typep (g:content-type-icon "image/cgm") 'g:themed-icon)))

;;;   g_content_type_get_symbolic_icon

(test content-type-symbolic-icon
  (is (typep (g:content-type-symbolic-icon "image/cgm") 'g:themed-icon)))

;;;   g_content_type_get_generic_icon_name

#-windows ; On Windows we have no generic icon name
(test content-type-generic-icon-name
  (is (every #'stringp
             (mapcar #'g:content-type-generic-icon-name
                     (g:content-types-registered)))))

;;;   g_content_type_can_be_executable
;;;   g_content_type_from_mime_type
;;;   g_content_type_guess
;;;   g_content_type_guess_for_tree

;;;   g_content_types_get_registered

(test content-types-registered
  (is (every #'stringp (g:content-types-registered))))

;;; 2022-10-27
