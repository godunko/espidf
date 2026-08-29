
## ESP-IDF Error Handling

Many ESP-IDF functions return an error code.
For each underlying C function, the Ada bindings provide _both_ of the following subprograms:

* A `function` that returns the raw ESP-IDF error code directly, allowing manual error inspection.
* A `procedure` that automatically checks the returned code via `ESPIDF.Ada_ESP_Check_Error` and raises an `ESPIDF.ESPIDF_Error` exception if an error is detected.

## Binding Incomplete C Struct Types

Incomplete C struct types are bound as `limited private` types whose full declaration is a `null record` with `Convention => C`.

Access types (pointers) for these struct types are named by appending a `_ptr` suffix to the C type name.

Example

```
   type esp_netif_t is limited private;

   type esp_netif_t_ptr is access all esp_netif_t
     with Convention => C;

private

   type esp_netif_t is limited null record
     with Convention => C;
   -- Full declaration of this type is not visible in "esp_netif.h"
```
