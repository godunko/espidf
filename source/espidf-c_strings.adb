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

   -----------------
   -- As_char_ptr --
   -----------------

   function As_char_ptr (Item : in out char_array) return char_ptr is
   begin
      return Item (Item'First)'Unchecked_Access;
   end As_char_ptr;

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

   -----------------
   -- Free_String --
   -----------------

   procedure Free_String (Item : in out const_char_ptr) is
      function As_Address is
        new Ada.Unchecked_Conversion (const_char_ptr, System.Address);

      procedure free (ptr : System.Address)
        with Import, Convention => C, External_Name => "free";

   begin
      if Item /= null then
         free (As_Address (Item));
         Item := null;
      end if;
   end Free_String;

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

   ----------------
   -- New_String --
   ----------------

   function New_String (Item : String) return const_char_ptr is
      function As_const_char_ptr is
        new Ada.Unchecked_Conversion (System.Address, const_char_ptr);

      function malloc (size : size_t) return System.Address
        with Import, Convention => C, External_Name => "malloc";

      Result : System.Address;

   begin
      Result := malloc (Item'Length + 1);

      declare
         Src : constant char_array (0 .. Item'Length - 1)
           with Import, Convention => C, Address => Item'Address;
         Dst : char_array (0 .. Item'Length)
           with Import, Convention => C, Address => Result;

      begin
         Dst (Src'Range) := Src;
         Dst (Dst'Last)  := nul;
      end;

      return As_const_char_ptr (Result);
   end New_String;

   --------------------------
   -- To_char_array_string --
   --------------------------

   function To_char_array_string
     (Item : char_array) return char_array_string
   is
      Length : uint32_t := 0;

   begin
      for C of Item loop
         exit when C = nul;

         Length := @ + 1;
      end loop;

      return Result : char_array_string (0 .. Length) do
         for J in 0 .. Length - 1 loop
            Result (Result'First + J) := Item (Item'First + J);
         end loop;

         Result (Result'Last) := nul;
      end return;
   end To_char_array_string;

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

   --------------------------
   -- To_char_array_string --
   --------------------------

   function To_char_array_string
     (Pointer    : const_char_ptr;
      Max_Length : uint32_t) return char_array_string
   is
      Iterator : const_char_ptr := Pointer;
      Index    : uint32_t       := 0;
      Length   : uint32_t       := 0;

   begin
      --  First, compute the length of the resulting array, which is limited
      --  by `Max_Length`.

      if Pointer /= null then
         while Iterator.all /= nul and then Length < Max_Length loop
            Length   := @ + 1;
            Iterator := @ + 1;
         end loop;
      end if;

      --  Allocate the resulting array with the computed length and fill it
      --  with the characters from the original C string.

      return Result : char_array_string (0 .. Length) do
         if Pointer /= null then
            Iterator := Pointer;

            while Iterator.all /= nul and then Index < Length loop
               Result (Index) := Iterator.all;
               Index    := @ + 1;
               Iterator := @ + 1;
            end loop;
         end if;

         Result (Result'Last) := nul;
      end return;
   end To_char_array_string;

   ---------------
   -- To_String --
   ---------------

   function To_String (chars : char_array_string) return String is
   begin
      return To_String (As_const_char_ptr (chars));
   end To_String;

   ---------------
   -- To_String --
   ---------------

   function To_String (Pointer : const_char_ptr) return String is
      Iterator : const_char_ptr := Pointer;
      Offset   : Natural := 0;

   begin
      return Result : String (1 .. Natural (Length (Pointer))) do
         if Pointer /= null then
            while Iterator.all /= nul loop
               Result (Result'First + Offset) := Character (Iterator.all);
               Offset   := @ + 1;
               Iterator := @ + 1;
            end loop;
         end if;
      end return;
   end To_String;

end ESPIDF.C_Strings;