# Ada/ESP-IDF Binding

This is the base crate for Ada bindings to the ESP-IDF (Espressif IoT Development Framework).
It provides the foundational type definitions and root package hierarchy required to build Ada applications for Espressif SoC platforms.

## Key Features

 * Core Definitions: Establishes the root namespace and basic types used throughout the binding ecosystem.
 * Runtime Compatibility: Designed to be used in tandem with the ESP-IDF GNAT Runtime for a seamless embedded Ada experience. 
 * Hand-Crafted Specs: Eschews automated generation scripts in favor of clean, idiomatic Ada specs that respect the language's strong typing.
 * Modular Design: To minimize footprint, this crate contains only the essentials. Specialized functionality is distributed via separate crates.

## Ecosystem

The following crates build upon this base layer:

 * [espidf_console](https://github.com/godunko/espidf_console): binding of ESP-IDF Console
 * [espidf_driver_i2c](https://github.com/godunko/espidf_driver_i2c): bindings of the I2C peripheral driver
 * (More components coming soon)

## Getting Started: Project Template

To jumpstart your development, we provide a [ESP32C3 Project Template](https://github.com/godunko/esp32c3_template) and [ESP32S3 Project Template](https://github.com/godunko/esp32s3_template) that configures the GNAT project files and ESP-IDF build environment specifically for corresponsing MCU.

## Usage

Once your project structure is set up from the Project Template, the development workflow involves two main steps:

1. Ada Dependencies: Use Alire to include the binding's crates into your Ada application.

```
alr with espidf_console
alr with espidf_driver_i2c
```

2. ESP-IDF Components: The related ESP-IDF C components must be explicitly added to your main/CMakeLists.txt to ensure they are linked during the build process:

```
idf_component_register(
    REQUIRES esp_driver_i2c)
...
add_prebuilt_library(app_main "${COMPONENT_LIB}"
    REQUIRES esp_driver_i2c)
```

3. Build

The project can then be built using the standard ESP-IDF workflow (e.g., `idf.py build`), which will invoke the GNAT compiler for the Ada sources and link them with the specified IDF components.
