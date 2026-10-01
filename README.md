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
 * Event Loop Library ([espidf_event](https://github.com/godunko/espidf_event))
 * FAT Filesystem Support ([espidf_fatfs](https://github.com/godunko/espidf_fatfs))
 * HTTP Server ([espidf_http_server](https://github.com/godunko/espidf_http_server))
 * mDNS Service ([espidf_mdns](https://github.com/godunko/espidf_mdns))
 * ESP-NETIF ([espidf_netif](https://github.com/godunko/espidf_netif))
 * Non-Volatile Storage Library ([espidf_nvs_flash](https://github.com/godunko/espidf_nvs_flash))
 * Partitions API ([espidf_partition](https://github.com/godunko/espidf_partition))
 * SPIFFS Filesystem ([espidf_spiffs](https://github.com/godunko/espidf_spiffs))
 * Wear Levelling API ([espidf_wear_levelling](https://github.com/godunko/espidf_wear_levelling))
 * USB Device Stack ([espidf_tinyusb](https://github.com/godunko/espidf_tinyusb))
   * Mass Storage Class ([espidf_tinyusb_msc](https://github.com/godunko/espidf_tinyusb_msc))
 * Wi-Fi ([espidf_wifi](https://github.com/godunko/espidf_wifi))
 * (More components coming soon)

## Getting Started: Project Template

To jumpstart your development, we provide templates that configure the GNAT project files and ESP-IDF build environment specifically for corresponsing MCU.

 * For ESP32-C3 (RISC-V): [ESP32C3 Project Template](https://github.com/godunko/esp32c3_template)
 * For ESP32 (Xtensa, LX6): [ESP32 Project Template](https://github.com/RREE/esp32_template)
 * For ESP32-S3 (Xtensa, LX7): [ESP32S3 Project Template](https://github.com/godunko/esp32s3_template)

## Usage

Once your project structure is set up from the Project Template, the development workflow involves the following steps:

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

3. Build Environment: Some binding crates contain C glue code, which can be compiled only inside the ESP-IDF build environment.
By default only Ada sources are compiled (this allows Alire to build the crates standalone, e.g. when publishing), so the application must enable compilation of C sources in its `alire.toml`:

```
[configuration.values]
espidf.Build_Environment = "espidf"
```

4. Build

The project can then be built using the standard ESP-IDF workflow (e.g., `idf.py build`), which will invoke the GNAT compiler for the Ada sources and link them with the specified IDF components.
