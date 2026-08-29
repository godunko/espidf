--
--  Copyright (C) 2026, Vadim Godunko
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

with GNAT.Source_Info;

procedure ESPIDF.Ada_ESP_Check_Error
  (Code     : esp_err_t;
   Location : String := GNAT.Source_Info.Source_Location;
   Entity   : String := GNAT.Source_Info.Enclosing_Entity)
     with Preelaborate;
--  Raises ESPIDF_Error if Error is not ESP_OK.
