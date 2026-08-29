
## ESP-IDF Error Handling

Many ESP-IDF functions return an error code. These functions are exposed in Ada via two patterns:

 * Functions that return the raw error code directly.
 * Procedures that automatically handle the check by passing the code to `ESPIDF.Ada_ESP_Check_Error`, raising an `ESPIDF.ESPIDF_Error` exception if an error occurs.
