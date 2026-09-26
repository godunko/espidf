# Documenting ESP-IDF Bindings

Ada specs of `espidf*` crates (except `espidf_gnat_runtime`) are documented
in GNATdoc format. Documentation is converted from Doxygen comments of the
corresponding ESP-IDF C headers and adapted to the Ada profile of the
bound entity.

`espidf_nvs_flash/source/espidf-nvs_flash.ads` is the reference example.

## Sources

Documentation is taken from ESP-IDF v6.0.3 (`$IDF_PATH`) and from managed
components (`managed_components/espressif__*`).

| Ada spec | C header(s) |
| :--- | :--- |
| `espidf/source/espidf.ads` | `components/esp_common/include/esp_err.h` |
| `espidf_event/source/espidf-event.ads` | `components/esp_event/include/esp_event.h`, `esp_event_base.h` |
| `espidf_fatfs/source/espidf-fatfs.ads` | `components/fatfs/vfs/esp_vfs_fat.h` |
| `espidf_http_server/source/espidf-http_server.ads` | `components/esp_http_server/include/esp_http_server.h` |
| `espidf_mdns/source/espidf-mdns.ads` | `espressif__mdns/include/mdns.h` |
| `espidf_netif/source/espidf-netif.ads` | `components/esp_netif/include/esp_netif*.h` |
| `espidf_netif/source/espidf-sockets.ads` | `components/lwip/` (mostly undocumented) |
| `espidf_nvs_flash/source/espidf-nvs_flash.ads` | `components/nvs_flash/include/nvs.h`, `nvs_flash.h` |
| `espidf_partition/source/espidf-partition.ads` | `components/esp_partition/include/esp_partition.h` |
| `espidf_spiffs/source/espidf-spiffs.ads` | `components/spiffs/include/esp_spiffs.h` |
| `espidf_tinyusb/source/espidf-tinyusb.ads` | `espressif__esp_tinyusb/include/tinyusb.h`, `tinyusb_default_config.h` |
| `espidf_tinyusb_msc/source/espidf-tinyusb-msc.ads` | `espressif__esp_tinyusb/include/tinyusb_msc.h` |
| `espidf_wear_levelling/source/espidf-wear_levelling.ads` | `components/wear_levelling/include/wear_levelling.h` |
| `espidf_wifi/source/espidf-wifi*.ads` | `components/esp_wifi/include/esp_wifi.h`, `esp_wifi_types_generic.h`, `esp_wifi_default.h` |

## Layout

* Documentation comment is placed **after** the declaration. For a type
  with a representation clause, it is placed between the type declaration
  and the representation clause.
* Empty lines break a documentation block. Use an empty `--` line as a
  paragraph separator.
* Tags follow the text directly, without separator lines before or after.
* Lines are limited to 79 columns; comment text starts with two spaces
  after `--`.
* Tag text that doesn't fit on the tag line continues on following lines,
  indented by two extra spaces.

## Tags

* `@param <name> <text>` - uses the **Ada** parameter name.
* `@return <text>` - for functions.
* `@raise ESPIDF_Error <text>` - for raising procedures (not `@exception`).
* `@enum <literal> <text>` - for enumeration literals, in the type's
  documentation.
* `@field <name> <text>` - for visible record components.

## References to Entities

* References to entities (subprograms, types, parameters, constants) inside
  text are enclosed in backticks: `` `nvs_open` ``, `` `ESP_OK` ``.
* The name that directly follows a tag is written **without** backticks:
  `@param handle ...`, `@raise ESPIDF_Error ...`, `@enum NVS_READONLY ...`.
* C `func()` references are written as `` `func` ``.

## Return Code Lists

`@return` and `@raise ESPIDF_Error` lists of error codes use one uniform
format in all crates:

```
   --  @return
   --    - `ESP_OK` if the changes have been written successfully
   --    - `ESP_ERR_NVS_INVALID_HANDLE` if handle has been closed or is NULL
   --    - other error codes from the underlying storage driver
```

* Each item is `` - `CODE` if <condition> ``: no colon after the code,
  condition starts with a lowercase letter.
* `ESP_OK` states what succeeded (`` `ESP_OK` if handler was registered
  successfully ``), not just "on success".
* Catch-all item is lowercase: `- other error codes from ...`.
* No trailing `;` or `.`, except for items with several sentences.
* Values that aren't error codes use the same pattern
  (`- number of bytes read into the buffer if successful`).
* Bullet lists that aren't return codes (option IDs, lists of related
  APIs) keep their own form.

## Conversion from Doxygen

* `@brief` becomes the first paragraph.
* `@note`, `@warning`, `@attention` become paragraphs (`Note: ...`).
* `@param[in]`, `@param[out]`, `@param[inout]` become `@param`.
* C code examples are dropped.
* C-only concepts are dropped or reworded: NULL pointer arguments, buffer
  length arguments that don't exist in the Ada profile, `*_DEFAULT_CONFIG`
  macros (objects are initialized automatically), fields that can't be set
  from Ada.
* Obvious typos of the header may be fixed (e.g. `CONFIG_CONFIG_...`).
* C entities that aren't bound are still referenced in backticks when the
  C text mentions them.

## Per-Entity Rules

* **Imported function** returning `esp_err_t`: full description, `@param`
  for each parameter, `@return` list.
* **Raising procedure** of a function/procedure pair: **full duplicate** of
  the function's description and `@param`s; the return code list without
  `ESP_OK` becomes `@raise ESPIDF_Error raised on error:` list.
* **Overloads**: each overload gets its own full documentation.
* **Ada wrappers with changed profile**: C text is adapted to the Ada
  profile; check the `.adb` body for behavior (e.g. handle reset to null
  value by `nvs_close`, `httpd_stop`).
* **Types**: enumerations, private struct/handle types, callback access
  types, from the typedef or struct documentation.
* **Constants** (`ESP_ERR_*`, event IDs, static constant functions): short
  trailing comment from `/*!< ... */` member comment.
* **Configuration setters** (`Set_*`): from the C struct field comment,
  `@param` for the value.
* **Existing Ada comments** are kept; Ada-specific notes follow the
  converted text.
* Entities without documentation in the C header are left undocumented;
  documentation isn't invented. Private parts aren't documented.

## Example

```ada
   procedure nvs_commit (handle : nvs_handle_t);
   --  Write any pending changes to non-volatile storage.
   --
   --  After setting any values, `nvs_commit` must be called to ensure
   --  changes are written to non-volatile storage. Individual
   --  implementations may write to storage at other times, but this is not
   --  guaranteed.
   --  @param handle
   --    Storage handle obtained with `nvs_open`. Handles that were opened
   --    read only cannot be used.
   --  @raise ESPIDF_Error raised on error:
   --    - `ESP_ERR_NVS_INVALID_HANDLE` if handle has been closed or is NULL
   --    - other error codes from the underlying storage driver
```

## Verification

Syntax and line length check of the spec (run in a temporary directory):

```
gcc -c -gnats -gnatyM79 -gnat2022 <path>/<spec>.ads
```

Check that only comment lines were changed:

```
git diff | grep '^[-+]' | grep -v '^+++\|^---' | grep -v '^[-+] *--' | grep -v '^[-+]$'
```

Check return code list format (leftovers should be non-return-code lists
only):

```
grep -nE '^\s*--\s+- `[A-Za-z_0-9]+`' <spec>.ads | grep -vE '`[A-Za-z_0-9]+` if '
```
