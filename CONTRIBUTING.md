
## Binding of `char*` and `const char*`

`char*` and `const char*` types are commonly used in C to transfer both string and binary data. Because C does not convey ownership transfer or memory safety rules through its type system, the following conventions are used when binding these types to Ada API:

### 1. `const char*` (Read-Only Strings)

* **String with immediate copy:** Map to `char_array_string` when the C function expects a null-terminated string and creates an internal copy of the data during the call.
* **String with persistent lifetime:** Map to `const_char_ptr` when the content is a null-terminated string, but the C API expects the application to manage and guarantee the string's lifetime for later use.

Note: this rules need to be extended for mutable/out/raw byte sequences

---

### Mapping Quick Reference

| C Parameter Type | Content Type | Ownership / Lifetime | Recommended Ada Mapping |
| :--- | :--- | :--- | :--- |
| `const char*` | Null-terminated string | Copied immediately by C | `char_array_string` |
| `const char*` | Null-terminated string | Application retains ownership | `const_char_ptr` |

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

### Binding C Types with Zero Default Initialization

When binding C struct types that require zero-initialization by default, use the Ada record template below.
This pattern ensures that any instances of the type declared in Ada are automatically initialized to zero (all bytes set to `0`) without explicit assignment, matching standard C runtime expectations for zeroed structures.

```
   type esp_partition_t is limited private;

private

   sizeof_esp_partition_t : constant int
     with Import, Convention => C,
          External_Name => "__ada_SIZEOF_esp_partition_t";

   type esp_partition_t is new C_Object_Storage (1 .. sizeof_esp_partition_t)
     with Convention              => C,
          Default_Component_Value => 0;
```

```
const int __ada_SIZEOF_esp_partition_t = sizeof(struct esp_partition_t);

```

## Binding Types with Non-Zero Default Initialization

For C struct types that require specific, non-zero default field values (such as configurations initialized via C macros like `HTTPD_DEFAULT_CONFIG()`), Ada bindings encapsulate the C struct as a limited, private, finalizable type.

The binding imports the byte size of the underlying C type and utilizes GNAT's Generalized Finalization extension via the `Finalizable` aspect. Specifying `Relaxed_Finalization => True` allows a limited record to automatically run a C-side initialization function upon object declaration.

```
   type httpd_config_t is limited private;

private

   sizeof_httpd_config_t : constant int
      with Import, Convention => C,
           Link_Name => "__ada_SIZEOF_httpd_config_t";

   type httpd_config_t_Storage is
     new C_Object_Storage (1 .. sizeof_httpd_config_t)
       with Convention => C;

   procedure Initialize (Self : in out httpd_config_t);

   type httpd_config_t is limited record
      Storage : httpd_config_t_Storage;
   end record
     with Convention  => C,
          Finalizable =>
            (Initialize           => Initialize,
             Relaxed_Finalization => True);

   pragma Assert (httpd_config_t'Size = sizeof_httpd_config_t * C_Storage_Element'Size);
```

```
   ----------------
   -- Initialize --
   ----------------

   procedure Initialize (Self : in out httpd_config_t) is

      procedure Imported (config : out httpd_config_t)
        with Import, Convention => C,
             External_Name => "__ada_HTTPD_DEFAULT_CONFIG";

   begin
      Imported (Self);
   end Initialize;
```

```
const int __ada_SIZEOF_httpd_config_t = sizeof(httpd_config_t);

void __ada_HTTPD_DEFAULT_CONFIG(httpd_config_t *cfg)
{
    *cfg = (httpd_config_t)HTTPD_DEFAULT_CONFIG();
}
```
