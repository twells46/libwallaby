# libwallaby

The library for interfacing with KIPR robot controllers.
The name comes from the previous generation controller, the Wallaby, but the current controller is the Wombat.

The Wombat is built on a Raspberry Pi 3b+ with a specially designed HAT that allows interfacing with the various peripherals that comprise a KIPR robot.

## Building

### CMake Options

- `with_python_binding`: Build python bindings, default `ON`
- `with_xml_binding`: Build XML bindings, default `ON`
- `with_documentation`: Enable documentation, default `ON`
- `with_tests`: Enable tests, default `ON`
- `with_accel`: Enable accel API, default `ON`
- `with_analog`: Enable analog API, default `ON`
- `with_battery`: Enable battery API, default `ON`
- `with_botball`: Enable botball API, default `ON`
- `with_button`: Enable button API, default `ON`
- `with_camera`: Enable camera API, default `ON`
- `with_compass`: Enable compass API, default `ON`
- `with_console`: Enable console API, default `ON`
- `with_create`: Enable Create API, default `ON`
- `with_digital`: Enable digital API, default `ON`
- `with_graphics`: Enable graphics API, default `ON`
- `with_gyro`: Enable gyro API, default `ON`
- `with_magneto`: Enable magnetometer API, default `ON`
- `with_motor`: Enable motor API, default `ON`
- `with_network`: Enable network API, default `ON`
- `with_servo`: Enable servo API, default `ON`
- `with_tello`: Enable tello API, default `ON`
- `with_thread`: Enable thread/mutex API, default `ON`
- `with_time`: Enable time API, default `ON`
- `with_wait_for`: Enable wait_for API, default `ON`
- `package_debian`: Build a Debian package, default `OFF`
- `wasm`: Build for WASM dynamic linking, default `OFF`

### Cross-compilation

This project has CMake toolchain definitions for both 32-bit ARM and 64-bit arm (`aarch64`).
There is generally no reason to use 32-bit on modern builds as the Pi 3B+ has full 64-bit support.

#### 32-bit

```sh
sudo apt install gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf
cmake -Bbuild -DCMAKE_TOOLCHAIN_FILE=toolchain/arm-linux-gnueabihf.cmake .
```

#### 64-bit

```sh
sudo apt install gcc-aarch64-linux-gnu g++-aarch64-linux-gnu
cmake -Bbuild -DCMAKE_TOOLCHAIN_FILE=toolchain/aarch64-linux-gnu.cmake .
```