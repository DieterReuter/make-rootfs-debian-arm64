#!/bin/bash -e
set -x

#touch rootfs.tar.gz

# Debootstrap a minimal Debian Jessie rootfs 
qemu-debootstrap \
  --arch=arm64 \
  --keyring /usr/share/keyrings/debian-archive-keyring.gpg 
  --variant=buildd \
  --exclude=debfoster \
  --include=net-tools \
  jessie \
  debian-arm64 \
  http://ftp.debian.org/debian

# set root user
chroot debian-arm64 \
   echo "root:shield" | chpasswd

# Package tarball
tar -czf /data/rootfs.tar.gz -C debian-arm64/ .   
