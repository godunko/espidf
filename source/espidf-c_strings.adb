--
--  Copyright (C) 2026, Vadim Godunko
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

pragma Ada_2022;

with Ada.Unchecked_Conversion;
with System.Storage_Elements;

package body ESPIDF.C_Strings is

   use type System.Storage_Elements.Storage_Offset;

   function "+"
     (Left  : const_char_ptr;
      Right : uint32_t) return const_char_ptr;

   function "+"
     (Left  : const_char_ptr_const_array;
      Right : uint32_t) return const_char_ptr_const_array;

   ---------
   -- "+" --
   ---------

   function "+"
     (Left  : const_char_ptr;
      Right : uint32_t) return const_char_ptr
   is
      function To_Address is
        new Ada.Unchecked_Conversion (const_char_ptr, System.Address);

      function To_const_char_ptr is
        new Ada.Unchecked_Conversion (System.Address, const_char_ptr);

   begin
      if Left = null then
         return null;

      else
         return
           To_const_char_ptr
             (To_Address (Left)
                + System.Storage_Elements.Storage_Offset
                    (char'Max_Size_In_Storage_Elements * Right));
      end if;
   end "+";

   ---------
   -- "+" --
   ---------

   function "+"
     (Left  : const_char_ptr_const_array;
      Right : uint32_t) return const_char_ptr_const_array
   is
      function To_Address is
        new Ada.Unchecked_Conversion
              (const_char_ptr_const_array, System.Address);

      function To_const_char_ptr is
        new Ada.Unchecked_Conversion
              (System.Address, const_char_ptr_const_array);

   begin
      if Left = null then
         return null;

      else
         return
           To_const_char_ptr
             (To_Address (Left)
                + System.Storage_Elements.Storage_Offset
                    (const_char_ptr'Max_Size_In_Storage_Elements * Right));
      end if;
   end "+";

   -----------------------
   -- As_const_char_ptr --
   -----------------------

   function As_const_char_ptr
     (Item : char_array_string) return const_char_ptr is
   begin
      return Item (Item'First)'Unchecked_Access;
   end As_const_char_ptr;

   -------------
   -- Element --
   -------------

   function Element
     (Pointer : const_char_ptr_const_array;
      Index   : uint32_t) return const_char_ptr is
   begin
      if Pointer = null or else Index > Length (Pointer) then
         return null;

      else
         declare
            Item_Pointer : constant const_char_ptr_const_array :=
              Pointer + Index;

         begin
            return Item_Pointer.all;
         end;
      end if;
   end Element;

   ------------
   -- Length --
   ------------

   function Length (Pointer : const_char_ptr) return uint32_t is
      Iterator : const_char_ptr := Pointer;

   begin
      return Result : uint32_t := 0 do
         if Pointer /= null then
            while Iterator.all /= nul loop
               Result   := Result + 1;
               Iterator := Iterator + 1;
            end loop;
         end if;
      end return;
   end Length;

   ------------
   -- Length --
   ------------

   function Length (Pointer : const_char_ptr_const_array) return uint32_t is
      Iterator : const_char_ptr_const_array := Pointer;

   begin
      return Result : uint32_t := 0 do
         if Pointer /= null then
            while Iterator.all /= null loop
               Result   := Result + 1;
               Iterator := Iterator + 1;
            end loop;
         end if;
      end return;
   end Length;

   --------------------------
   -- To_char_array_string --
   --------------------------

   function To_char_array_string
     (Pointer : const_char_ptr) return char_array_string
   is
      Iterator : const_char_ptr := Pointer;
      Index    : uint32_t       := 0;

   begin
      return Result : char_array_string (0 .. Length (Pointer)) do
         if Pointer /= null then
            while Iterator.all /= nul loop
               Result (Index) := Iterator.all;
               Index    := @ + 1;
               Iterator := @ + 1;
            end loop;
         end if;

         Result (Result'Last) := nul;
      end return;
   end To_char_array_string;

end ESPIDF.C_Strings;