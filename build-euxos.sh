#!/usr/bin/env bash
set -euo pipefail

ISO_NAME="EuxOS.iso"
WORKDIR="euxos-build"
ISO_DIR="$WORKDIR/iso"
ROOTFS_DIR="$WORKDIR/rootfs"

echo "[1/8] Install build tools..."
apt update
DEBIAN_FRONTEND=noninteractive apt install -y \
  grub-pc-bin \
  grub-common \
  xorriso \
  mtools \
  busybox-static \
  cpio \
  gzip \
  linux-image-generic

echo "[2/8] Prepare folders..."
rm -rf "$WORKDIR" "$ISO_NAME"
mkdir -p "$ISO_DIR/boot/grub"
mkdir -p "$ROOTFS_DIR"/{bin,etc,proc,sys,dev,tmp,usr/bin,home/root}

echo "[3/8] Create root filesystem..."
cp /bin/busybox "$ROOTFS_DIR/bin/busybox"
chmod +x "$ROOTFS_DIR/bin/busybox"

for app in sh ls cat echo mount umount clear dmesg mkdir rmdir touch uname sleep reboot poweroff ps free df grep vi; do
  ln -sf /bin/busybox "$ROOTFS_DIR/bin/$app"
done

cat > "$ROOTFS_DIR/init" <<'EOF'
#!/bin/sh

mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev 2>/dev/null || mount -t tmpfs none /dev

clear
cat /etc/euxos-release

echo ""
echo "Welcome to EuxOS Preview ISO"
echo "This is a minimal bootable ISO using Linux kernel + BusyBox."
echo ""
echo "Try commands:"
echo "  ls"
echo "  uname -a"
echo "  free"
echo "  df"
echo "  reboot"
echo ""
echo "Starting EuxOS shell..."
echo ""

exec /bin/sh
EOF

chmod +x "$ROOTFS_DIR/init"

cat > "$ROOTFS_DIR/etc/euxos-release" <<'EOF'
███████╗██╗   ██╗██╗  ██╗ ██████╗ ███████╗
██╔════╝██║   ██║╚██╗██╔╝██╔═══██╗██╔════╝
█████╗  ██║   ██║ ╚███╔╝ ██║   ██║███████╗
██╔══╝  ██║   ██║ ██╔██╗ ██║   ██║╚════██║
███████╗╚██████╔╝██╔╝ ██╗╚██████╔╝███████║
╚══════╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝

EuxOS Preview 0.1
Private. Smart. Fluid.
EOF

echo "[4/8] Build initramfs..."
(
  cd "$ROOTFS_DIR"
  find . -print0 | cpio --null -ov --format=newc | gzip -9 > "../initrd.img"
)

cp "$WORKDIR/initrd.img" "$ISO_DIR/boot/initrd.img"

echo "[5/8] Copy Linux kernel..."
KERNEL="$(ls /boot/vmlinuz-* | sort -V | tail -n 1)"
cp "$KERNEL" "$ISO_DIR/boot/vmlinuz"

echo "[6/8] Create GRUB menu..."
cat > "$ISO_DIR/boot/grub/grub.cfg" <<'EOF'
set timeout=5
set default=0

menuentry "EuxOS Preview 0.1" {
    linux /boot/vmlinuz quiet
    initrd /boot/initrd.img
}

menuentry "EuxOS Preview 0.1 - Debug Mode" {
    linux /boot/vmlinuz
    initrd /boot/initrd.img
}
EOF

echo "[7/8] Build ISO..."
grub-mkrescue -o "$ISO_NAME" "$ISO_DIR"

echo "[8/8] Done."
ls -lh "$ISO_NAME"
