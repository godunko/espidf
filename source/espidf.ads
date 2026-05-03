--
--  Copyright (C) 2026, Vadim Godunko
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

pragma Ada_2022;

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
   ESP_FAIL                 : constant esp_err_t := -1;

   ESP_ERR_NO_MEM           : constant esp_err_t := 16#101#;
   ESP_ERR_INVALID_ARG      : constant esp_err_t := 16#102#;
   ESP_ERR_INVALID_STATE    : constant esp_err_t := 16#103#;
   ESP_ERR_INVALID_SIZE     : constant esp_err_t := 16#104#;
   ESP_ERR_NOT_FOUND        : constant esp_err_t := 16#105#;
   ESP_ERR_NOT_SUPPORTED    : constant esp_err_t := 16#106#;
   ESP_ERR_TIMEOUT          : constant esp_err_t := 16#107#;
   ESP_ERR_INVALID_RESPONSE : constant esp_err_t := 16#108#;
   ESP_ERR_INVALID_CRC      : constant esp_err_t := 16#109#;
   ESP_ERR_INVALID_VERSION  : constant esp_err_t := 16#10A#;
   ESP_ERR_INVALID_MAC      : constant esp_err_t := 16#10B#;
   ESP_ERR_NOT_FINISHED     : constant esp_err_t := 16#10C#;
   ESP_ERR_NOT_ALLOWED      : constant esp_err_t := 16#10D#;

   function nul return char is (Interfaces.C.nul) with Static;

end ESPIDF;
