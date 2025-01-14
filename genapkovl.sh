#!/bin/sh -e

PROFILE="$1"

cleanup() {
    rm -rf "$tmp"
}

makefile() {
    OWNER="$1"
    PERMS="$2"
    FILENAME="$3"
    cat > "$FILENAME"
    chown "$OWNER" "$FILENAME"
    chmod "$PERMS" "$FILENAME"
}

rc_add() {
    mkdir -p "$tmp"/etc/runlevels/"$2"
    ln -sf /etc/init.d/"$1" "$tmp"/etc/runlevels/"$2"/"$1"
}

tmp="$(mktemp -d)"
trap cleanup EXIT

cp -R /apkovl/* "$tmp"/

mkdir -p "$tmp"/etc
ln -s /usr/share/zoneinfo/UTC "$tmp"/etc/localtime

makefile root:root 0644 "$tmp"/etc/hostname <<EOF
${HOSTNAME}
EOF

mkdir -p "$tmp"/etc/apk
makefile root:root 0644 "$tmp"/etc/apk/repositories <<EOF
/media/mmcblk0p1/apks
https://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION}/main
https://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION}/community
EOF

mkdir -p "$tmp"/etc/init.d
makefile root:root 0744 "$tmp"/etc/init.d/ssh-setup <<EOF
#!/sbin/openrc-run

depend() {
    need localmount
}

start() {
    if [ -f /media/mmcblk0p1/authorized_keys ] && [ ! -f /root/.ssh/authorized_keys ]; then
        einfo "Configuring ssh authorized keys ..."
        mkdir -p /root/.ssh
        chmod 0700 /root/.ssh
        cp /media/mmcblk0p1/authorized_keys /root/.ssh/authorized_keys
        chmod 0600 /root/.ssh/authorized_keys
        rc-update add sshd
    fi
}
EOF

mkdir -p "$tmp"/etc/init.d
makefile root:root 0744 "$tmp"/etc/init.d/wpa_supplicant-setup <<EOF
#!/sbin/openrc-run

depend() {
    need localmount
    before networking
}

start() {
    if [ -f /media/mmcblk0p1/wpa_supplicant.conf ]; then
        einfo "Configuring WPA supplicant ..."
        cp /media/mmcblk0p1/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf
        chmod 0644 /etc/wpa_supplicant/wpa_supplicant.conf
        rc-update add wpa_supplicant
        rc-service wpa_supplicant start
    fi
}
EOF

rc_add devfs sysinit
rc_add dmesg sysinit
rc_add mdev sysinit
rc_add hwdrivers sysinit
rc_add modloop sysinit
rc_add swclock boot
rc_add modules boot
rc_add sysctl boot
rc_add hostname boot
rc_add bootmisc boot
rc_add syslog boot
rc_add haveged boot
rc_add urandom boot
rc_add wpa_supplicant-setup boot
rc_add networking boot
rc_add ssh-setup boot
rc_add mount-ro shutdown
rc_add killprocs shutdown
rc_add savecache shutdown

rc_add chronyd default

tar -c -C "$tmp" $(cd "$tmp" && echo *) | gzip -9n > "$PROFILE.apkovl.tar.gz"
