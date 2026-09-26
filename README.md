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
 * [espidf_driver_gpio](https://github.com/RREE/espidf_driver_gpio): bindings for setting and reading GPIOs
 * [espidf_driver_i2c](https://github.com/godunko/espidf_driver_i2c): bindings of the I2C peripheral driver
 * [espidf_event](https://github.com/godunko/espidf_event): bindings of Event Loop library
 * [espidf_fatfs](https://github.com/godunko/espidf_fatfs): bindings of FAT Filesystem Support component
 * [espidf_http_server](https://github.com/godunko/espidf_http_server) bindings of HTTP Server
 * [espidf_mdns](https://github.com/godunko/espidf_mdns) bindings of ESP-Protocols mDNS Service
 * [espidf_netif](https://github.com/godunko/espidf_netif): bindings of ESP-IDF NETIF library
 * [espidf_nvs_flash](https://github.com/godunko/espidf_nvs_flash): bindings of ESP-IDF Non-Volatile Storage Library
 * [espidf_partition](https://github.com/godunko/espidf_partition): bindings of Partition API
 * [espidf_spiffs](https://github.com/godunko/espidf_spiffs): bindings of ESP-IDF SPIFFS Filesystem
 * [espidf_wear_levelling](https://github.com/godunko/espidf-wear_levelling): bindings of Wear Levelling API
 * [espidf_tinyusb](https://github.com/godunko/espidf_tinyusb): bindings of USB driver
 * [espidf_tinyusb_msc](https://github.com/godunko/espidf_tinyusb_msc): bindings of USB Mass Storage Class
 * [espidf_wifi](https://github.com/godunko/espidf_wifi): bindings of ESP-IDF WiFi
 * (More components coming soon)

## Getting Started: Project Template

To jumpstart your development, we provide templates that configure the GNAT project files and ESP-IDF build environment specifically for corresponsing MCU.

 * For ESP32-C3 (RISC-V): [ESP32C3 Project Template](https://github.com/godunko/esp32c3_template)
 * For ESP32 (Xtensa, LX6): [ESP32 Project Template](https://github.com/RREE/esp32_template)
 * For ESP32-S3 (Xtensa, LX7): [ESP32S3 Project Template](https://github.com/godunko/esp32s3_template)

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
