#!/bin/bash -e
set -x
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
  --exclude=debfoster \
  --include=net-tools \
  jessie \
  "${ROOTFS_DIR}" \
  http://ftp.debian.org/debian

### HypriotOS specific settings ###

# set hostname to 'black-pearl'
echo 'black-pearl' | ${SUDO_CMD} chroot "${ROOTFS_DIR}" tee /etc/hostname

# set root password to 'hypriot'
echo 'root:hypriot' | ${SUDO_CMD} chroot "${ROOTFS_DIR}" /usr/sbin/chpasswd

# set ethernet interface eth0 to dhcp
cat << EOM | ${SUDO_CMD} chroot ${ROOTFS_DIR} tee /etc/network/interfaces.d/eth0.cfg
# The network interface
auto eth0
iface eth0 inet dhcp
EOM

# Package rootfs tarball
umask 0000
tar -czf "rootfs-${BUILD_ARCH}.tar.gz" -C "${ROOTFS_DIR}/" .
