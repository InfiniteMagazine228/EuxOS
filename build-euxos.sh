# ==========================================================

cat > "$ROOTFS_DIR/init" <<'EOF'
#!/bin/sh

mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev 2>/dev/null || mount -t tmpfs none /dev

clear
cat /etc/euxos-release

echo ""
echo "Chào mừng đến với EuxOS Preview ISO"
echo "Đây là bản ISO tối giản chạy bằng Linux kernel + BusyBox."
echo ""
echo "Lệnh thử:"
echo "  ls"
echo "  uname -a"
echo "  free"
echo "  df"
echo "  reboot"
echo ""
echo "Đăng nhập shell EuxOS..."
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

cat > "$ROOTFS_DIR/etc/motd" <<'EOF'
Welcome to EuxOS.
EOF

# --------- Tạo initramfs ---------
echo "[4/8] Đóng gói initramfs..."
(
  cd "$ROOTFS_DIR"
  find . -print0 | cpio --null -ov --format=newc | gzip -9 > "../initrd.img"
)
cp "$WORKDIR/initrd.img" "$ISO_DIR/boot/initrd.img"

# --------- Copy Linux kernel từ hệ thống host ---------
echo "[5/8] Copy Linux kernel..."
KERNEL="$(ls /boot/vmlinuz-* | sort -V | tail -n 1)"
if [ ! -f "$KERNEL" ]; then
  echo "Không tìm thấy kernel trong /boot/vmlinuz-*"
  exit 1
fi
cp "$KERNEL" "$ISO_DIR/boot/vmlinuz"

# --------- Tạo menu GRUB ---------
echo "[6/8] Tạo GRUB boot menu..."
cat > "$ISO_DIR/boot/grub/grub.cfg" <<EOF
set timeout=5
set default=0

menuentry "EuxOS Preview 0.1" {
    linux /boot/vmlinuz quiet boot=euxos
    initrd /boot/initrd.img
}

menuentry "EuxOS Preview 0.1 - Debug Mode" {
    linux /boot/vmlinuz boot=euxos debug
    initrd /boot/initrd.img
}
EOF

# --------- Build ISO ---------
echo "[7/8] Build ISO bootable..."
grub-mkrescue -o "$ISO_NAME" "$ISO_DIR"

# --------- Hoàn tất ---------
echo "[8/8] Hoàn tất!"
echo ""
echo "ISO đã tạo: $ISO_NAME"
echo ""
echo "Chạy thử bằng QEMU:"
echo "  qemu-system-x86_64 -cdrom $ISO_NAME -m 1024"
echo ""
echo "Hoặc mở bằng VirtualBox / VMware như một file ISO bình thường."
