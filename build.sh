#!/bin/bash -e
set -x
# This script only works on Linux
if [ "$(uname -s)" != "Linux" ]; then
  echo "ERROR: scripts works on Linux only, not on $(uname -s)!"
  exit 1
fi

# Redefine sudo command, when not available
if [ "$(whoami)" == "root" ]; then
  SUDO_CMD=""
else
  SUDO_CMD="sudo"
fi

# Build Debian rootfs for ARCH={armhf,arm64}
# - Debian armhf = ARMv6/ARMv7
# - Debian arm64 = ARMv8/Aarch64
BUILD_ARCH="${BUILD_ARCH:-arm64}"
ROOTFS_DIR="debian-${BUILD_ARCH}"

# Cleanup
rm -fr "${ROOTFS_DIR}"

# Debootstrap a minimal Debian Jessie rootfs 
#  --keyring /usr/share/keyrings/debian-ports-archive-keyring.gpg \
#  --no-check-gpg \
#  --variant=buildd \
qemu-debootstrap \
  --arch="${BUILD_ARCH}" \
  --include=avahi-daemon,net-tools,openssh-server \
  --exclude=debfoster \
  jessie \
  "${ROOTFS_DIR}" \
  http://ftp.debian.org/debian


### Configure Debian ###

# Use standard Debian apt repositories
cat << EOM | ${SUDO_CMD} chroot "${ROOTFS_DIR}" \
  tee /etc/apt/sources.list.d/debian.list
deb http://httpredir.debian.org/debian jessie main
deb-src http://httpredir.debian.org/debian jessie main
EOM


### Configure network and systemd services ###

# Set ethernet interface eth0 to dhcp
cat << EOM | ${SUDO_CMD} chroot "${ROOTFS_DIR}" \
  tee /etc/systemd/network/eth0.network
[Match]
Name=eth0

[Network]
DHCP=yes
EOM

# Enable networkd
${SUDO_CMD} chroot "${ROOTFS_DIR}" \
  systemctl enable systemd-networkd

# Configure and enable resolved
${SUDO_CMD} chroot "${ROOTFS_DIR}" \
  ln -sfv /run/systemd/resolve/resolv.conf /etc/resolv.conf
${SUDO_CMD} chroot "${ROOTFS_DIR}" \
  systemctl enable systemd-resolved

# Enable SSH root login
${SUDO_CMD} chroot "${ROOTFS_DIR}" \
  sed -i 's|PermitRootLogin without-password|PermitRootLogin yes|g' /etc/ssh/sshd_config

# Enable NTP with timesyncd
${SUDO_CMD} chroot "${ROOTFS_DIR}" \
  sed -i 's|#Servers=|Servers=|g' /etc/systemd/timesyncd.conf
${SUDO_CMD} chroot "${ROOTFS_DIR}" \
  systemctl enable systemd-timesyncd


### HypriotOS specific settings ###

# set hostname to 'black-pearl'
echo 'black-pearl' | ${SUDO_CMD} chroot "${ROOTFS_DIR}" \
  tee /etc/hostname

# set root password to 'hypriot'
echo 'root:hypriot' | ${SUDO_CMD} chroot "${ROOTFS_DIR}" \
  /usr/sbin/chpasswd


# Package rootfs tarball
umask 0000
tar -czf "rootfs-${BUILD_ARCH}.tar.gz" -C "${ROOTFS_DIR}/" .
