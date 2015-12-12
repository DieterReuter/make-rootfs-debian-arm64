#!/bin/bash -e
set -x

# Cleanup
rm -fr debian-arm64

# Debootstrap a minimal Debian Jessie rootfs 
# --keyring /usr/share/keyrings/debian-ports-archive-keyring.gpg \
# --no-check-gpg \
qemu-debootstrap \
  --arch=arm64 \
  --variant=buildd \
  --exclude=debfoster \
  --include=net-tools \
  jessie \
  debian-arm64 \
  http://ftp.debian.org/debian

# set root password to 'hypriot'
echo 'root:hypriot' | sudo chroot debian-arm64 /usr/sbin/chpasswd

# Package rootfs tarball
tar -czf rootfs.tar.gz -C debian-arm64/ .
