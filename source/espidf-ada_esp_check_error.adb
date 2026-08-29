--
--  Copyright (C) 2026, Vadim Godunko
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

pragma Ada_2022;

with Ada.Unchecked_Conversion;

with ESPIDF.C_Strings;

procedure ESPIDF.Ada_ESP_Check_Error
  (Code     : esp_err_t;
   Location : String := GNAT.Source_Info.Source_Location;
   Entity   : String := GNAT.Source_Info.Enclosing_Entity)
is

   function esp_err_to_name
     (code : esp_err_t) return ESPIDF.C_Strings.const_char_ptr
      with Import, Convention => C, External_Name => "esp_err_to_name";

   function Hex_Image (Code : esp_err_t) return String;

   ---------------
   -- Hex_Image --
   ---------------

   function Hex_Image (Code : esp_err_t) return String is

      function As_Unsigned_32 is
        new Ada.Unchecked_Conversion (esp_err_t, Interfaces.Unsigned_32);

      To_Hex : constant
        array (Interfaces.Unsigned_32 range 0 .. 15) of Character :=
          "0123456789ABCDEF";

      Buffer : String (1 .. 8);
      Index  : Natural := Buffer'Last;
      Value  : Interfaces.Unsigned_32 := As_Unsigned_32 (Code);

   begin
      loop
         Buffer (Index) := To_Hex (Value mod 16);
         Value := @ / 16;

         exit when Value = 0;

         Index := @ - 1;
      end loop;

      return Buffer (Index .. Buffer'Last);
   end Hex_Image;

begin
   if Code /= ESP_OK then
      raise ESPIDF_Error
        with Hex_Image (Code)
               & " (" & ESPIDF.C_Strings.To_String (esp_err_to_name (Code))
               & ") at " & Location & " (" & Entity & ")";
   end if;
end ESPIDF.Ada_ESP_Check_Error;