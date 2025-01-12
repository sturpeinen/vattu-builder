# Custom Raspberry Pi Alpine Linux image builder

## Usage

```
$ ./build.sh
Usage: build.sh HOSTNAME ARCH

Parameters:
  HOSTNAME    The hostname for the target image.
  ARCH        The target architecture. Valid values are:
                - aarch64 (Raspberry Pi 3, 3+, 4, 5 and Zero 2)
                - armv7 (Raspberry Pi 2, 3, 3+ and Zero 2)
                - armhf (Raspberry Pi 1 and Zero)
```

```
$ ./build.sh amazing aarch64
...
$ ls -l build
total 148200
-rw-r--r--@ 1 keimo  staff  75877809 Jan 12 14:37 amazing-3.21.2-aarch64.tar.gz
```

## Configuring ethernet

To enable or configure ethernet, edit the `eth0` lines from the
`apkovl/etc/network/interfaces` file before building the image.

## Configuring Wi-Fi

To enable or configure Wi-fi, edit the `wlan0` lines from the
`apkovl/etc/network/interfaces` file before building the image.

After unpacking the image to SD card, add `wpa_supplicant.conf` file to the
root of the SD card. `wpa_supplicant` service will not start without this file.

Example of `wpa_supplicant.conf`:
```
network={
    ssid="<ssid goes here>"
    psk="<password goes here>" # Or psk=NONE for open Wi-Fi
}
```

## Enabling SSH

To change `sshd` settings, edit the `apkovl/etc/ssh/sshd_config` file before
building the image.

After unpacking the image to SD card, copy `authorized_keys` file to the root
of the SD card. `sshd` service will not start without this file.

NOTE: SSH host keys are re-generated on every boot.

## Adding packages

Before building the image, add the package names to `apks` list in the 
`mkimg.vattu.sh`. This includes the packages in the image but doesn't install
them. To install the packages, add them also to `apkovl/etc/apk/world` file.

If the packages require configuration, add the configurations to the `apkovl`
directory. To enable possible services, add `rc_add <service name> default` to
the end of the `genapkovl.sh`.
