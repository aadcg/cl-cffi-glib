(in-package :glib-test)

(def-suite glib-stable-pointer :in glib-suite)
(in-suite glib-stable-pointer)

(test glib-stable-pointer-value
  (let* ((length (glib::get-stable-pointers-length))
         (counter (glib::get-stable-pointers-counter))
         (func (lambda () 88))
         (ptr (glib:allocate-stable-pointer func)))
    (is (<= counter length))
    (is (= (1+ counter) (glib::get-stable-pointers-counter)))
    (is (every (lambda (x) (or (null x)
                               (cffi:pointerp x)
                               (functionp x)))
                 (glib::get-stable-pointers)))
    (is (= 88 (funcall (glib:get-stable-pointer-value ptr))))
    (is-false (glib:free-stable-pointer ptr))
    (is-false (glib:get-stable-pointer-value ptr))
    (is (<= counter length))
    (is (= counter (glib::get-stable-pointers-counter)))
    (is (every (lambda (x) (or (null x)
                               (cffi:pointerp x)
                               (functionp x)))
                 (glib::get-stable-pointers)))))

(test with-stable-pointer
  (flet ((func () 888))
    (let ((length (glib::get-stable-pointers-length))
          (counter (glib::get-stable-pointers-counter)))
      (with-stable-pointer (ptr #'func)
        (is (<= counter length))
        (is (= (1+ counter) (glib::get-stable-pointers-counter)))
        (is (= 888 (funcall (glib:get-stable-pointer-value ptr)))))
      (is (<= counter length))
      (is (= counter (glib::get-stable-pointers-counter))))))

;;; --- 2023-5-29 --------------------------------------------------------------
