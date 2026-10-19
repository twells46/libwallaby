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

## AI Camera

The AI camera is a Raspberry Pi Zero that connects to the Wombat over USB and talks to it using IP over USB.
`libwallaby` detects it automatically when a camera is opened.

### Prebuilt testing builds

To test without building, flash your Wombat with the [AI camera testing image](https://files.kipr.org/wombat/Wombat_v32.0.0-aicam_beta_20251119.img.gz), or install the [prebuilt `.deb`](https://files.kipr.org/devel/kipr-1.2.2-Linux.deb).
Both were built on 2025-11-19 and do not include later changes.
For newer changes, follow [Building](#building), which produces a `.deb` in the `build` directory.

### Installation

First, plug the Pi Zero into the Wombat, then SSH into the Wombat and create the necessary connection:

```sh
sudo nmcli connection add type ethernet con-name ai-camera-link ifname usb0 ipv4.addresses 192.168.1.1/24 ipv4.method manual ipv6.method auto ipv6.addresses "fe80::c3ed:d6c2:1e76:cebe/64" ipv6.routes "fe80::/64 :: 101"
```

The connection should come up quickly (under 30 seconds).
You can verify it by SSHing from the Wombat to the Pi Zero:

```sh
ssh kipr@192.168.1.2
```

The Wombat will be rebooted later, so you may wish to power off the Pi Zero now to avoid potential disk corruption:

```sh
sudo poweroff
```

Now install the new version of `libwallaby`:

1. Copy the `.deb` file to the Wombat:

   ```sh
   scp kipr-<ver>-Linux.deb kipr@<wombat_ip>:~
   ```

2. SSH into the Wombat and install it:

   ```sh
   sudo apt install ./kipr-<ver>-Linux.deb
   ```

3. Reboot:

   ```sh
   sudo reboot
   ```

### Channel data

Objects found by the AI camera are delivered through a blob tracking channel, which can be configured through BotUI → Settings → Channels.
The channel is currently configured using "QR code scanner"; a future release will use a more appropriate name.

The fields of the channel object structure are used as follows:

- `m_centroid` - centroid
- `m_bounding_box` - bounding box
- `m_confidence` - confidence
- `m_data` - string from the model that indicates the object type
- `m_length` - length of that string

In short, objects look the same as blob tracking objects and are accessed through the existing functions.

Downloading AI models from the Wombat is not yet supported.

### Debugging with systemd

`botui` on the Wombat runs as a systemd unit.
You can follow a unit's logs with:

```sh
sudo journalctl -b -f -u <service-name>.service
```

So, for `botui`:

```sh
sudo journalctl -b -f -u botui.service
```

Flags:

- `-b`: Only show logs from the current boot.
- `-f`: Emulates `tail -f` with a continuous stream.
- `-u UNIT`: Only view logs for `UNIT`, rather than everything systemd is tracking.

See `man journalctl` for more info.
You can also list everything systemd is currently tracking by running `systemctl`.
Generally the entries suffixed with `.service` are the most pertinent.

## License

libkipr is licensed under the terms of the [GPLv3 License](LICENSE).
