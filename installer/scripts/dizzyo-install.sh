#!/bin/bash
set -e

# DizzyoOS Installer - Graphical installer with bootloader selection
if [ "$(id -u)" -ne 0 ]; then
  kdialog --title "DizzyoOS Installer" --error "This installer must be run as root.\nRight-click the desktop shortcut and select Run as Root."
  exit 1
fi

# Welcome
kdialog --title "DizzyoOS 1.0.0 Installer" --msgbox "Welcome to the DizzyoOS Installer!\n\nThis will install DizzyoOS to your hard drive.\nYou can choose your bootloader in the next steps."

# Bootloader selection
BOOTLOADER=$(kdialog --title "Bootloader Selection" --radiolist "Choose your bootloader:" \
  1 "GRUB (BIOS + UEFI) - Most compatible" on \
  2 "systemd-boot (UEFI only) - Fast and simple" off \
  3 "Skip bootloader - For dual-boot setups" off)

if [ -z "$BOOTLOADER" ]; then
  kdialog --title "DizzyoOS Installer" --error "Installation cancelled."
  exit 1
fi

# Partition selection
DISKS=$(lsblk -dno NAME,SIZE | grep -E "^sd|^vd|^nvme" | awk '{print "/dev/" $1 " (" $2 ")"}')
DEVICE=$(kdialog --title "Select Disk" --combobox "Choose target disk:" $DISKS)
DEVICE=$(echo "$DEVICE" | cut -d" " -f1)

if [ -z "$DEVICE" ]; then
  kdialog --title "DizzyoOS Installer" --error "No disk selected."
  exit 1
fi

# Confirm
kdialog --title "DizzyoOS Installer" --yesno "WARNING: All data on $DEVICE will be erased!\n\nProceed with installation?"
if [ $? -ne 0 ]; then
  kdialog --title "DizzyoOS Installer" --msgbox "Installation cancelled."
  exit 0
fi

# Partition the disk
(
echo "label: gpt"
echo "unit: sectors"
echo ""
echo "/dev/efi : size=512MiB, type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B"
echo "/ : type=4F68BCE3-E8CD-4DB1-96E7-FBCAF984B709"
) | sfdisk --no-reread "$DEVICE"

sleep 2
partprobe "$DEVICE" 2>/dev/null || true
sleep 2

PART_ROOT="${DEVICE}2"
if [ ! -b "$PART_ROOT" ]; then
  PART_ROOT="${DEVICE}p2"
fi
PART_ESP="${DEVICE}1"
if [ ! -b "$PART_ESP" ]; then
  PART_ESP="${DEVICE}p1"
fi

mkfs.fat -F32 "$PART_ESP"
mkfs.ext4 -F "$PART_ROOT"

# Mount
mount "$PART_ROOT" /mnt
mkdir -p /mnt/boot
mount "$PART_ESP" /mnt/boot

# Copy live system
(
echo "10"
echo "# Copying system files..."
) | kdialog --title "DizzyoOS Installer" --progressbar "Installing DizzyoOS to disk..." 4

for dir in bin sbin lib lib64 usr etc var boot opt; do
  cp -ax "/$dir" "/mnt/$dir" 2>/dev/null || true
done

mkdir -p /mnt/{proc,sys,dev,tmp,run,root,opt,mnt,srv,home}
mkdir -p /mnt/dev/{pts,shm}

# Generate fstab
UUID_ROOT=$(blkid -s UUID -o value "$PART_ROOT")
UUID_ESP=$(blkid -s UUID -o value "$PART_ESP")
echo "UUID=$UUID_ROOT / ext4 defaults 0 1" > /mnt/etc/fstab
echo "UUID=$UUID_ESP /boot vfat defaults 0 2" >> /mnt/etc/fstab

# Configure installed system
echo "dizzyo" > /mnt/etc/hostname
printf "127.0.0.1 localhost\n::1 localhost\n127.0.1.1 dizzyo dizzyo.localdomain\n" > /mnt/etc/hosts
echo "dizzyo ALL=(ALL) NOPASSWD:ALL" > /mnt/etc/sudoers.d/dizzyo
chmod 440 /mnt/etc/sudoers.d/dizzyo
systemctl --root=/mnt enable sddm NetworkManager 2>/dev/null || true

# Install bootloader
(
echo "75"
echo "# Installing bootloader..."
) | kdialog --title "DizzyoOS Installer" --progressbar "Installing bootloader..." 4

case "$BOOTLOADER" in
  1|GRUB*)
    arch-chroot /mnt bash -c "grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=DizzyoOS --recheck 2>&1"
    arch-chroot /mnt bash -c "grub-install --target=i386-pc --recheck $DEVICE 2>&1" || true
    arch-chroot /mnt bash -c "grub-mkconfig -o /boot/grub/grub.cfg"
    ;;
  2|systemd*)
    arch-chroot /mnt bash -c "bootctl install 2>&1" || true
    arch-chroot /mnt bash -c "kernel-install add $(ls /mnt/boot/vmlinuz-linux | sed 's|.*/||') /boot/vmlinuz-linux" || true
    ;;
  3|Skip*)
    echo "Skipping bootloader installation."
    ;;
esac

# Finalize
(
echo "100"
echo "# Done!"
) | kdialog --title "DizzyoOS Installer" --progressbar "Finalizing installation..." 4

kdialog --title "DizzyoOS Installer" --msgbox "Installation complete!\n\nRemove the installation media and click OK to reboot."
umount -R /mnt 2>/dev/null || true
reboot
