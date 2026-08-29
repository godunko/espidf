
## ESP-IDF Error Handling

Many ESP-IDF functions return an error code.
For each underlying C function, the Ada bindings provide _both_ of the following subprograms:

* A `function` that returns the raw ESP-IDF error code directly, allowing manual error inspection.
* A `procedure` that automatically checks the returned code via `ESPIDF.Ada_ESP_Check_Error` and raises an `ESPIDF.ESPIDF_Error` exception if an error is detected.
