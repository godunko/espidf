--
--  Copyright (C) 2026, Vadim Godunko
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

with Interfaces.C;

package ESPIDF with Pure is

   subtype bool     is Interfaces.C.C_bool;
   subtype char     is Interfaces.C.char;      use type char;
   subtype int      is Interfaces.C.int;
   subtype uint8_t  is Interfaces.Unsigned_8;
   subtype uint16_t is Interfaces.Unsigned_16;
   subtype uint32_t is Interfaces.Unsigned_32; use type uint32_t;
   subtype size_t   is Interfaces.C.size_t;

   type esp_err_t is new int;

   ESP_OK                   : constant esp_err_t := 0;
   ESP_ERR_INVALID_RESPONSE : constant esp_err_t := 16#108#;

   function nul return char is (Interfaces.C.nul);

end ESPIDF;
