# libwallaby

The library for interfacing with KIPR robot controllers.
The name comes from the previous generation controller, the Wallaby, but the current controller is the Wombat.
For that reason, this is sometimes referred to generically as `libkipr`.

The Wombat is built on a Raspberry Pi 3b+ with a specially designed HAT that allows interfacing with the various peripherals that comprise a KIPR robot.
Therefore, the primary `libwallaby` deployment target is 64-bit Arm, also known as `aarch64` or `arm64`.
The secondary target is WASM for use in the [KIPR online simulator](https://github.com/kipr/Simulator).

## Building

Build a full-featured release for use on a KIPR Wombat:

```sh
cmake -Bbuild -DCMAKE_TOOLCHAIN_FILE=toolchain/aarch64-linux-gnu.cmake .
cmake --build build -j "$(nproc)"
```

Or build with Docker:
```sh
docker build -t libwallaby-builder .
docker run --rm --mount type=bind,source=.,destination=/src/ libwallaby-builder sh -c 'cmake -B/src/build -DCMAKE_TOOLCHAIN_FILE=/src/toolchain/aarch64-linux-gnu.cmake /src && cmake --build /src/build -j "$(nproc)"'
```

### CMake Options

Refer to the following table for an overview of the options for building this project.
**Deps** lists Debian 13 package names of required dependencies, you may need to change if building elsewhere.

| Option              | Description           | Default value | Deps |
|---------------------|-----------------------|---------------|------|
`with_python_binding` | Build python bindings | `ON` | `swig python3.13-dev` |
`with_xml_binding` | Build XML bindings | `ON` | `swig`  |
`with_documentation` | Enable documentation | `ON` | `doxygen` |
`with_tests` | Enable tests | `ON` | |
`with_accel` | Enable accel API | `ON` | |
`with_analog` | Enable analog API | `ON` | |
`with_battery` | Enable battery API | `ON` | |
`with_botball` | Enable botball API | `ON` | |
`with_button` | Enable button API | `ON` | |
`with_camera` | Enable camera API | `ON` | |
`with_compass` | Enable compass API | `ON` | |
`with_console` | Enable console API | `ON` | |
`with_digital` | Enable digital API | `ON` | |
`with_graphics` | Enable graphics API | `ON` | `libx11-dev` |
`with_gyro` | Enable gyro API | `ON` | |
`with_magneto` | Enable magnetometer API | `ON` | |
`with_motor` | Enable motor API | `ON` | |
`with_network` | Enable network API | `ON` | |
`with_servo` | Enable servo API | `ON` | |
`with_thread` | Enable thread/mutex API | `ON` | |
`with_time` | Enable time API | `ON` | |
`with_wait_for` | Enable wait_for API | `ON` | |
`package_debian` | Build a Debian package | `ON` | |
`wasm` | Build for WASM dynamic linking | `OFF` | |

### Cross-compilation

This project has CMake toolchain definitions for both 32-bit ARM and 64-bit arm (`aarch64`).
There is generally no reason to use 32-bit on modern builds as the Pi 3B+ has 64-bit support.

If building with options that require system libraries like `libx11-dev` or `python3.13-dev`, you will need to ensure that you have the appropriate architecture versions installed.
On Debian this is fairly simple:

```sh
sudo dpkg --add-architecture arm64
sudo apt update
sudo apt install libx11-dev:arm64 python3.13-dev:arm64
```

#### Arm 32-bit (`armv7`)

```sh
sudo apt install gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf
cmake -Bbuild -DCMAKE_TOOLCHAIN_FILE=toolchain/arm-linux-gnueabihf.cmake .
```

#### Arm 64-bit (`arm64`/`aarch64`)

```sh
sudo apt install gcc-aarch64-linux-gnu g++-aarch64-linux-gnu
cmake -Bbuild -DCMAKE_TOOLCHAIN_FILE=toolchain/aarch64-linux-gnu.cmake .
```
