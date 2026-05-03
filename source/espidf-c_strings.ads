--
--  Copyright (C) 2026, Vadim Godunko
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--  This package provides data types and subprograms for interfacing with C
--  strings and arrays of C strings.
--
--  This package provides the following types:
--    - `char_array_string`: An array of `char` with a null terminator,
--      representing a C string.
--    - `char_ptr`: A pointer to a C string (null-terminated array of `char`).
--    - `const_char_ptr`: A pointer to a constant C string (null-terminated
--      array of `char`).
--    - `char_ptr_array`: A pointer to an array of pointers to C strings.
--    - `const_char_ptr_const_array`: A pointer to a constant array of
--      pointers to constant C strings.
--
--  The package also provides functions for converting between these types,
--  calculating the length of C strings and arrays of C strings, and accessing
--  accessing elements of arrays of C strings.
--
--  Caller is responsible for ensuring that any pointers returned by the
--  functions or passed to the subprograms in this package remain valid for
--  the duration of their use.

package ESPIDF.C_Strings with Pure is

   type char_array_string is array (uint32_t range <>) of aliased char
     with Convention        => C,
          Dynamic_Predicate =>
            char_array_string'Length > 0
              and then
                char_array_string (char_array_string'Last) = Interfaces.C.nul
              and then (for all I in char_array_string'Range =>
                          I = char_array_string'Last
                            or else char_array_string (I) /= Interfaces.C.nul);
   --  This type represents a C string as an array of `char` with a null
   --  terminator. The dynamic predicate ensures that the array is not empty,
   --  that the last character is a null terminator, and that there are no
   --  null characters before the terminator.

   --------------
   -- char_ptr --
   --------------

   type char_ptr is private;

   --  type const_char_ptr is private;
   type const_char_ptr is access constant char
     with Convention => C, Storage_Size => 0;
   pragma No_Strict_Aliasing (const_char_ptr);
   --  Pointer to a constant C string (null-terminated array of `char`). This
   --  type is used to represent C strings that should not be modified.

   function As_const_char_ptr
     (Item : char_array_string) return const_char_ptr;
   --  Returns pointer to the first element of a `char_array_string` as a
   --  `const_char_ptr`.
   --
   --  Caller is responsible for ensuring that the `char_array_string` remains
   --  valid for the duration of the use of the returned pointer.

   function To_char_array_string
     (Pointer : const_char_ptr) return char_array_string;
   --  Creates and returns an object of `char_array_string` type from a
   --  `const_char_ptr`. Null-terminator is included in the resulting object.
   --
   --  For `null` pointer, an "empty" array is returned (with only the
   --  null-terminator).

   function Length (Pointer : const_char_ptr) return uint32_t;
   --  Returns the length of the C string pointed to by `Pointer`, not
   --  including the null-terminator. For a null pointer, returns 0.

   --------------------
   -- char_ptr_array --
   --------------------

   type char_ptr_array is access all char_ptr
     with Convention => C, Storage_Size => 0;
   pragma No_Strict_Aliasing (char_ptr_array);

   --------------------------------
   -- const_char_ptr_const_array --
   --------------------------------

   type const_char_ptr_const_array is access all const_char_ptr
     with Convention => C, Storage_Size => 0;
   pragma No_Strict_Aliasing (const_char_ptr_const_array);

   function Length (Pointer : const_char_ptr_const_array) return uint32_t;
   --  Returns the number of elements in the array of C strings pointed to by
   --  `Pointer`, not including the null pointer that terminates the array.
   --  For a null pointer, returns 0.

   function Element
     (Pointer : const_char_ptr_const_array;
      Index   : uint32_t) return const_char_ptr;
   --  Returns the `Index`-th element of the array pointed to by `Pointer`.
   --  The first element is at index 0.
   --
   --  Returns null for a null pointer or if the `Index` is out of bounds.

private

   type char_ptr is access all char
     with Convention => C, Storage_Size => 0;
   pragma No_Strict_Aliasing (char_ptr);

end ESPIDF.C_Strings;