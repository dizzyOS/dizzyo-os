# DizzyoOS Archiso Profile Definition
# https://wiki.archlinux.org/title/Archiso

iso_name="dizzyo-os"
iso_label="DIZZYO_OS"
iso_publisher="DizzyoOS <https://github.com/dizzyo-os>"
iso_application="DizzyoOS Live"
iso_version="$(date +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=('uefi-x64' 'bios')
arch=('x86_64')
pacman_conf='pacman.conf'
airootfs_image_type="squashfs"
airootfs_image_completion_tool='none'
airootfs_compress=("zstd" "-Xcompression-level" "19")
