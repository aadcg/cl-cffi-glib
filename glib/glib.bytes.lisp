;;; ----------------------------------------------------------------------------
;;; glib.bytes.lisp
;;;
;;; The documentation of this file is taken from the GLib 2.72 Reference
;;; Manual and modified to document the Lisp binding to the GLib library.
;;; See <http://www.gtk.org>. The API documentation of the Lisp binding is
;;; available from <http://www.crategus.com/books/cl-cffi-gtk/>.
;;;
;;; Copyright (C) 2021 -2023 Dieter Kaiser
;;;
;;; This program is free software: you can redistribute it and/or modify
;;; it under the terms of the GNU Lesser General Public License for Lisp
;;; as published by the Free Software Foundation, either version 3 of the
;;; License, or (at your option) any later version and with a preamble to
;;; the GNU Lesser General Public License that clarifies the terms for use
;;; with Lisp programs and is referred as the LLGPL.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU Lesser General Public License for more details.
;;;
;;; You should have received a copy of the GNU Lesser General Public
;;; License along with this program and the preamble to the Gnu Lesser
;;; General Public License.  If not, see <http://www.gnu.org/licenses/>
;;; and <http://opensource.franz.com/preamble.html>.
;;; ----------------------------------------------------------------------------
;;;
;;; Byte Arrays
;;;
;;;     Arrays of bytes
;;;
;;; Types and Values
;;;
;;;     GBytes
;;;
;;; Functions
;;;
;;;     g_bytes_new
;;;     g_bytes_new_take
;;;     g_bytes_new_static
;;;     g_bytes_new_with_free_func
;;;     g_bytes_new_from_bytes
;;;     g_bytes_get_data
;;;     g_bytes_get_size
;;;     g_bytes_hash
;;;     g_bytes_equal
;;;     g_bytes_compare
;;;     g_bytes_ref
;;;     g_bytes_unref
;;;     g_bytes_unref_to_data
;;;     g_bytes_unref_to_array
;;; ----------------------------------------------------------------------------

(in-package :glib)

;;; ----------------------------------------------------------------------------
;;; GBytes
;;; ----------------------------------------------------------------------------

(gobject::define-g-boxed-opaque bytes "GBytes"
  :alloc (bytes-new (cffi:null-pointer) 0))

#+liber-documentation
(setf (liber:alias-for-class 'bytes)
      "GBoxed"
      (documentation 'bytes 'type)
 "@version{2023-1-6}
  @begin{short}
    The @sym{g:bytes} structure is a simple refcounted data type representing 
    an immutable sequence of zero or more bytes from an unspecified origin.
  @end{short} The purpose of a @sym{g:bytes} instance is to keep the memory 
  region that it holds alive for as long as anyone holds a reference to the 
  bytes. When the last reference count is dropped, the memory is released. 
  Multiple unrelated callers can use byte data in the @sym{g:bytes} instance  
  without coordinating their activities, resting assured that the byte data 
  will not change or move while they hold a reference.

  A @sym{g:bytes} instance can come from many different origins that may have
  different procedures for freeing the memory region. Examples are memory from
  the @fun{g:malloc} function.
  @begin[Examples]{dictionary}
    Usage of a @sym{g:bytes} instance for a Lisp string as byte data.
    @begin{pre}
(multiple-value-bind (data len)
    (foreign-string-alloc \"A test string.\")
  (defvar bytes (g:bytes-new data len)))
=> BYTES
(g:bytes-size bytes)
=> 15
(g:bytes-data bytes)
=> #.(SB-SYS:INT-SAP #X55EBB2C1DB70)
=> 15
(foreign-string-to-lisp (g:bytes-data bytes))
=> \"A test string.\"
=> 14
    @end{pre}
  @end{dictionary}")

(export 'bytes)

;;; ----------------------------------------------------------------------------
;;; g_bytes_new () -> bytes-new
;;; ----------------------------------------------------------------------------

(defcfun ("g_bytes_new" bytes-new) (gobject:boxed bytes)
 #+liber-documentation
 "@version{2022-11-22}
  @argument[data]{a pointer to the data to be used for the bytes}
  @argument[size]{an integer with the size of @arg{data}}
  @return{A new @class{g:bytes} instance.}
  @short{Creates a new @class{g:bytes} instance from @arg{data}.}
  @see-class{g:bytes}"
  (data :pointer)
  (size :size))

(export 'bytes-new)

;;; ----------------------------------------------------------------------------
;;; g_bytes_new_take ()
;;;
;;; GBytes *
;;; g_bytes_new_take (gpointer data,
;;;                   gsize size);
;;;
;;; Creates a new GBytes from data .
;;;
;;; After this call, data belongs to the bytes and may no longer be modified by
;;; the caller. g_free() will be called on data when the bytes is no longer in
;;; use. Because of this data must have been created by a call to g_malloc(),
;;; g_malloc0() or g_realloc() or by one of the many functions that wrap these
;;; calls (such as g_new(), g_strdup(), etc).
;;;
;;; For creating GBytes with memory from other allocators, see
;;; g_bytes_new_with_free_func().
;;;
;;; data may be NULL if size is 0.
;;;
;;; data :
;;;     the data to be used for the bytes.
;;;
;;; size :
;;;     the size of data
;;;
;;; Returns :
;;;     a new GBytes.
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_bytes_new_static ()
;;;
;;; GBytes *
;;; g_bytes_new_static (gconstpointer data,
;;;                     gsize size);
;;;
;;; Creates a new GBytes from static data.
;;;
;;; data must be static (ie: never modified or freed). It may be NULL if size
;;; is 0.
;;;
;;; data :
;;;     the data to be used for the bytes.
;;;
;;; size :
;;;     the size of data
;;;
;;; Returns :
;;;     a new GBytes.
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_bytes_new_with_free_func ()
;;;
;;; GBytes *
;;; g_bytes_new_with_free_func (gconstpointer data,
;;;                             gsize size,
;;;                             GDestroyNotify free_func,
;;;                             gpointer user_data);
;;;
;;; Creates a GBytes from data .
;;;
;;; When the last reference is dropped, free_func will be called with the
;;; user_data argument.
;;;
;;; data must not be modified after this call is made until free_func has been
;;; called to indicate that the bytes is no longer in use.
;;;
;;; data may be NULL if size is 0.
;;;
;;; data :
;;;     the data to be used for the bytes.
;;;
;;; size :
;;;     the size of data
;;;
;;; free_func :
;;;     the function to call to release the data
;;;
;;; user_data :
;;;     data to pass to free_func
;;;
;;; Returns :
;;;     a new GBytes
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_bytes_new_from_bytes ()
;;;
;;; GBytes *
;;; g_bytes_new_from_bytes (GBytes *bytes,
;;;                         gsize offset,
;;;                         gsize length);
;;;
;;; Creates a GBytes which is a subsection of another GBytes. The offset +
;;; length may not be longer than the size of bytes .
;;;
;;; A reference to bytes will be held by the newly created GBytes until the byte
;;; data is no longer needed.
;;;
;;; Since 2.56, if offset is 0 and length matches the size of bytes , then bytes
;;; will be returned with the reference count incremented by 1. If bytes is a
;;; slice of another GBytes, then the resulting GBytes will reference the same
;;; GBytes instead of bytes . This allows consumers to simplify the usage of
;;; GBytes when asynchronously writing to streams.
;;;
;;; bytes :
;;;     a GBytes
;;;
;;; offset :
;;;     offset which subsection starts at
;;;
;;; length :
;;;     length of subsection
;;;
;;; Returns :
;;;     a new GBytes.
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_bytes_get_data ()
;;; ----------------------------------------------------------------------------

(defcfun ("g_bytes_get_data" %bytes-data) :pointer
  (bytes (gobject:boxed bytes))
  (size (:pointer :size)))

(defun bytes-data (bytes)
 #+liber-documentation
 "@version{2023-1-6}
  @argument[bytes]{a @class{g:bytes} instance}
  @begin{return}
    @arg{data} -- a pointer to the byte data, or a @code{null-pointer} value
    @br{}
    @arg{size} -- an integer with the size of the byte data
  @end{return}
  @begin{short}
    Get the byte data in the @class{g:bytes} instance.
  @end{short}
  This function will always return the same pointer for a given @class{g:bytes}
  instance.

  A @code{null-pointer} value may be returned if the @arg{size} value is 0. This
  is not guaranteed, as the @class{g:bytes} instance may represent an empty 
  string with @arg{data} not a @code{null-pointer} value and the @arg{size}
  value as 0. A @code{null-pointer} value will not be returned if the @arg{size} 
  value is non-zero.
  @see-class{g:bytes}"
  (with-foreign-object (size :size)
    (let ((ptr (%bytes-data bytes size)))
      (values ptr (cffi:mem-ref size :size)))))

(export 'bytes-data)

;;; ----------------------------------------------------------------------------
;;; g_bytes_get_size () -> bytes-size
;;; ----------------------------------------------------------------------------

(defcfun ("g_bytes_get_size" bytes-size) :size
 #+liber-documentation
 "@version{2022-11-22}
  @argument[bytes]{a @class{g:bytes} instance}
  @return{An integer with the size of the byte data.}
  @begin{short}
    Get the size of the byte data in the @class{g:bytes} instance.
  @end{short}
  This function will always return the same value for a given @class{g:bytes}
  instance.
  @see-class{g:bytes}"
  (bytes (gobject:boxed bytes)))

(export 'bytes-size)

;;; ----------------------------------------------------------------------------
;;; g_bytes_hash ()
;;;
;;; guint
;;; g_bytes_hash (gconstpointer bytes);
;;;
;;; Creates an integer hash code for the byte data in the GBytes.
;;;
;;; This function can be passed to g_hash_table_new() as the key_hash_func
;;; parameter, when using non-NULL GBytes pointers as keys in a GHashTable.
;;;
;;; bytes :
;;;     a pointer to a GBytes key.
;;;
;;; Returns :
;;;     a hash value corresponding to the key.
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_bytes_equal ()
;;;
;;; gboolean
;;; g_bytes_equal (gconstpointer bytes1,
;;;                gconstpointer bytes2);
;;;
;;; Compares the two GBytes values being pointed to and returns TRUE if they are
;;; equal.
;;;
;;; This function can be passed to g_hash_table_new() as the key_equal_func
;;; parameter, when using non-NULL GBytes pointers as keys in a GHashTable.
;;;
;;; bytes1 :
;;;     a pointer to a GBytes.
;;;
;;; bytes2 :
;;;     a pointer to a GBytes to compare with bytes1 .
;;;
;;; Returns :
;;;     TRUE if the two keys match.
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_bytes_compare ()
;;;
;;; gint
;;; g_bytes_compare (gconstpointer bytes1,
;;;                  gconstpointer bytes2);
;;;
;;; Compares the two GBytes values.
;;;
;;; This function can be used to sort GBytes instances in lexicographical order.
;;;
;;; If bytes1 and bytes2 have different length but the shorter one is a prefix
;;; of the longer one then the shorter one is considered to be less than the
;;; longer one. Otherwise the first byte where both differ is used for
;;; comparison. If bytes1 has a smaller value at that position it is considered
;;; less, otherwise greater than bytes2 .
;;;
;;; bytes1 :
;;;     a pointer to a GBytes.
;;;
;;; bytes2 :
;;;     a pointer to a GBytes to compare with bytes1 .
;;;
;;; Returns :
;;;     a negative value if bytes1 is less than bytes2 , a positive value if
;;;     bytes1 is greater than bytes2 , and zero if bytes1 is equal to bytes2
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_bytes_ref ()
;;;
;;; GBytes *
;;; g_bytes_ref (GBytes *bytes);
;;;
;;; Increase the reference count on bytes .
;;;
;;; bytes :
;;;     a GBytes
;;;
;;; Returns :
;;;     the GBytes
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_bytes_unref ()
;;;
;;; void
;;; g_bytes_unref (GBytes *bytes);
;;;
;;; Releases a reference on bytes . This may result in the bytes being freed. If
;;; bytes is NULL, it will return immediately.
;;;
;;; bytes :
;;;     a GBytes.
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_bytes_unref_to_data ()
;;;
;;; gpointer
;;; g_bytes_unref_to_data (GBytes *bytes,
;;;                        gsize *size);
;;;
;;; Unreferences the bytes, and returns a pointer the same byte data contents.
;;;
;;; As an optimization, the byte data is returned without copying if this was
;;; the last reference to bytes and bytes was created with g_bytes_new(),
;;; g_bytes_new_take() or g_byte_array_free_to_bytes(). In all other cases the
;;; data is copied.
;;;
;;; bytes :
;;;     a GBytes.
;;;
;;; size :
;;;     location to place the length of the returned data.
;;;
;;; Returns :
;;;     a pointer to the same byte data, which should be freed with g_free()
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_bytes_unref_to_array ()
;;;
;;; GByteArray *
;;; g_bytes_unref_to_array (GBytes *bytes);
;;;
;;; Unreferences the bytes, and returns a new mutable GByteArray containing the
;;; same byte data.
;;;
;;; As an optimization, the byte data is transferred to the array without
;;; copying if this was the last reference to bytes and bytes was created with
;;; g_bytes_new(), g_bytes_new_take() or g_byte_array_free_to_bytes(). In all
;;; other cases the data is copied.
;;;
;;; Do not use it if bytes contains more than G_MAXUINT bytes. GByteArray stores
;;; the length of its data in guint, which may be shorter than gsize, that bytes
;;; is using.
;;;
;;; bytes :
;;;     a GBytes.
;;;
;;; Returns .
;;;     a new mutable GByteArray containing the same byte data.
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; struct GByteArray
;;;
;;; struct GByteArray {
;;;   guint8 *data;
;;;   guint	  len;
;;; };
;;;
;;; Contains the public fields of a GByteArray.
;;;
;;; guint8 *data;
;;;     a pointer to the element data. The data may be moved as elements are
;;;     added to the GByteArray
;;;
;;; guint len;
;;;     the number of elements in the GByteArray
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_byte_array_new ()
;;;
;;; GByteArray *
;;; g_byte_array_new (void);
;;;
;;; Creates a new GByteArray with a reference count of 1.
;;;
;;; Returns :
;;;     the new GByteArray.
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_byte_array_steal ()
;;;
;;; guint8 *
;;; g_byte_array_steal (GByteArray *array,
;;;                     gsize *len);
;;;
;;; Frees the data in the array and resets the size to zero, while the
;;; underlying array is preserved for use elsewhere and returned to the caller.
;;;
;;; array :
;;;     a GByteArray.
;;;
;;; len :
;;;     pointer to retrieve the number of elements of the original array.
;;;
;;; Returns :
;;;     the element data, which should be freed using g_free().
;;;
;;; Since: 2.64
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_byte_array_new_take ()
;;;
;;; GByteArray *
;;; g_byte_array_new_take (guint8 *data,
;;;                        gsize len);
;;;
;;; Create byte array containing the data. The data will be owned by the array
;;; and will be freed with g_free(), i.e. it could be allocated using
;;; g_strdup().
;;;
;;; Do not use it if len is greater than G_MAXUINT. GByteArray stores the length
;;; of its data in guint, which may be shorter than gsize.
;;;
;;; data :
;;;     byte data for the array.
;;;
;;; len :
;;;     length of data
;;;
;;; Returns :
;;;     a new GByteArray.
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_byte_array_sized_new ()
;;;
;;; GByteArray *
;;; g_byte_array_sized_new (guint reserved_size);
;;;
;;; Creates a new GByteArray with reserved_size bytes preallocated. This avoids
;;; frequent reallocation, if you are going to add many bytes to the array. Note
;;; however that the size of the array is still 0.
;;;
;;; reserved_size :
;;;     number of bytes preallocated
;;;
;;; Returns :
;;;     the new GByteArray
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_byte_array_ref ()
;;;
;;; GByteArray *
;;; g_byte_array_ref (GByteArray *array);
;;;
;;; Atomically increments the reference count of array by one. This function is
;;; thread-safe and may be called from any thread.
;;;
;;; array :
;;;     A GByteArray
;;;
;;; Returns :
;;;     The passed in GByteArray
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_byte_array_unref ()
;;;
;;; void
;;; g_byte_array_unref (GByteArray *array);
;;;
;;; Atomically decrements the reference count of array by one. If the reference
;;; count drops to 0, all memory allocated by the array is released. This
;;; function is thread-safe and may be called from any thread.
;;;
;;; array :
;;;     A GByteArray
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_byte_array_append ()
;;;
;;; GByteArray *
;;; g_byte_array_append (GByteArray *array,
;;;                      const guint8 *data,
;;;                      guint len);
;;;
;;; Adds the given bytes to the end of the GByteArray. The array will grow in
;;; size automatically if necessary.
;;;
;;; array :
;;;     a GByteArray
;;;
;;; data :
;;;     the byte data to be added
;;;
;;; len :
;;;     the number of bytes to add
;;;
;;; Returns :
;;;     the GByteArray
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_byte_array_prepend ()
;;;
;;; GByteArray *
;;; g_byte_array_prepend (GByteArray *array,
;;;                       const guint8 *data,
;;;                       guint len);
;;;
;;; Adds the given data to the start of the GByteArray. The array will grow in
;;; size automatically if necessary.
;;;
;;; array :
;;;     a GByteArray
;;;
;;; data :
;;;     the byte data to be added
;;;
;;; len :
;;;     the number of bytes to add
;;;
;;; Returns :
;;;     the GByteArray
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_byte_array_remove_index ()
;;;
;;; GByteArray *
;;; g_byte_array_remove_index (GByteArray *array,
;;;                            guint index_);
;;;
;;; Removes the byte at the given index from a GByteArray. The following bytes
;;; are moved down one place.
;;;
;;; array :
;;;     a GByteArray
;;;
;;; index_:
;;;     the index of the byte to remove
;;;
;;; Returns :
;;;     the GByteArray
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_byte_array_remove_index_fast ()
;;;
;;; GByteArray *
;;; g_byte_array_remove_index_fast (GByteArray *array,
;;;                                 guint index_);
;;;
;;; Removes the byte at the given index from a GByteArray. The last element in
;;; the array is used to fill in the space, so this function does not preserve
;;; the order of the GByteArray. But it is faster than
;;; g_byte_array_remove_index().
;;;
;;; array :
;;;     a GByteArray
;;;
;;; index :_
;;;     the index of the byte to remove
;;;
;;; Returns :
;;;     the GByteArray
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_byte_array_remove_range ()
;;;
;;; GByteArray *
;;; g_byte_array_remove_range (GByteArray *array,
;;;                            guint index_,
;;;                            guint length);
;;;
;;; Removes the given number of bytes starting at the given index from a
;;; GByteArray. The following elements are moved to close the gap.
;;;
;;; array :
;;;     a GByteArray
;;;
;;; index_ :
;;;     the index of the first byte to remove
;;;
;;; length :
;;;     the number of bytes to remove
;;;
;;; Returns :
;;;     the GByteArray
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_byte_array_sort ()
;;;
;;; void
;;; g_byte_array_sort (GByteArray *array,
;;;                    GCompareFunc compare_func);
;;;
;;; Sorts a byte array, using compare_func which should be a qsort()-style
;;; comparison function (returns less than zero for first arg is less than
;;; second arg, zero for equal, greater than zero if first arg is greater than
;;; second arg).
;;;
;;; If two array elements compare equal, their order in the sorted array is
;;; undefined. If you want equal elements to keep their order (i.e. you want a
;;; stable sort) you can write a comparison function that, if two elements would
;;; otherwise compare equal, compares them by their addresses.
;;;
;;; array :
;;;     a GByteArray
;;;
;;; compare_func :
;;;     comparison function
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_byte_array_sort_with_data ()
;;;
;;; void
;;; g_byte_array_sort_with_data (GByteArray *array,
;;;                              GCompareDataFunc compare_func,
;;;                              gpointer user_data);
;;;
;;; Like g_byte_array_sort(), but the comparison function takes an extra user
;;; data argument.
;;;
;;; array :
;;;     a GByteArray
;;;
;;; compare_func :
;;;     comparison function
;;;
;;; user_data :
;;;     data to pass to compare_func
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_byte_array_set_size ()
;;;
;;; GByteArray *
;;; g_byte_array_set_size (GByteArray *array,
;;;                        guint length);
;;;
;;; Sets the size of the GByteArray, expanding it if necessary.
;;;
;;; array :
;;;     a GByteArray
;;;
;;; length :
;;;     the new size of the GByteArray
;;;
;;; Returns ;
;;;     the GByteArray
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_byte_array_free ()
;;;
;;; guint8 *
;;; g_byte_array_free (GByteArray *array,
;;;                    gboolean free_segment);
;;;
;;; Frees the memory allocated by the GByteArray. If free_segment is TRUE it
;;; frees the actual byte data. If the reference count of array is greater than
;;; one, the GByteArray wrapper is preserved but the size of array will be set
;;; to zero.
;;;
;;; array :
;;;     a GByteArray
;;;
;;; free_segment :
;;;     if TRUE the actual byte data is freed as well
;;;
;;; Returns :
;;;     the element data if free_segment is FALSE, otherwise NULL. The element
;;;     data should be freed using g_free().
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; g_byte_array_free_to_bytes ()
;;;
;;; GBytes *
;;; g_byte_array_free_to_bytes (GByteArray *array);
;;;
;;; Transfers the data from the GByteArray into a new immutable GBytes.
;;;
;;; The GByteArray is freed unless the reference count of array is greater than
;;; one, the GByteArray wrapper is preserved but the size of array will be set
;;; to zero.
;;;
;;; This is identical to using g_bytes_new_take() and g_byte_array_free()
;;; together.
;;;
;;; array :
;;;     a GByteArray
;;;
;;; Returns :
;;;     a new immutable GBytes representing same byte data that was in the array
;;; ----------------------------------------------------------------------------

;;; --- End of file glib.bytes.lisp --------------------------------------------
