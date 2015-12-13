#!/bin/bash -e
set -x

# Cleanup
rm -fr debian-arm64

# Debootstrap a minimal Debian Jessie rootfs 
#  --keyring /usr/share/keyrings/debian-ports-archive-keyring.gpg \
#  --no-check-gpg \
#  --variant=buildd \
qemu-debootstrap \
  --arch=arm64 \
  --exclude=debfoster \
  --include=net-tools \
  jessie \
  debian-arm64 \
  http://ftp.debian.org/debian

### HypriotOS specific settings ###

# set hostname to 'black-pearl'
echo 'black-pearl' | sudo chroot debian-arm64 tee /etc/hostname

# set root password to 'hypriot'
echo 'root:hypriot' | sudo chroot debian-arm64 /usr/sbin/chpasswd

# set ethernet interface eth0 to dhcp
cat << EOM | sudo chroot debian-arm64 tee /etc/network/interfaces.d/eth0.cfg
# The network interface
auto eth0
iface eth0 inet dhcp
EOM


# Package rootfs tarball
tar -czf rootfs.tar.gz -C debian-arm64/ .
