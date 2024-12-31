#!/usr/bin/env bash
set -euo pipefail
# Output green message prefixed with [+]
_info() { echo -e "\e[92m[+] ${1:-}\e[0m"; }
# Output orange message prefixed with [-]
_warn() { echo -e "\e[33m[-] ${1:-}\e[0m"; }
# Output red message prefixed with [!] and exit
_error() { echo -e >&2 "\e[31m[!] ${1:-}\e[0m"; exit 1; }

DISK="/dev/sda"
if [[ -z "$DISK" ]]; then
    _error "Set the DISK environment variable to continue"
fi

# Create a new partition table on the disk
parted "${DISK}" -s mklabel gpt
# Create a 500MiB FAT32 Boot Partition
parted "${DISK}" -s mkpart boot fat32 0% 500MiB
# Set the boot/esp flags on the boot partition
parted "${DISK}" set 1 boot on
# Create a single root partition
parted "${DISK}" -s mkpart root 500MiB 100%

_warn "Setting up disk encryption. Confirmation and password entry required"
root_part="2"

# luksFormat the root partition
cryptsetup luksFormat "${DISK}${root_part}"
_warn "Decrypting disk, password entry required"
# Open the encrypted container
cryptsetup open "${DISK}${root_part}" crytped
# Setup LVM physical volumes, volume groups and logical volumes
_info "Setting up the filesystem"

# Setup the filesystems
root_part=/dev/mapper/crytped

# Format the root partition
mkfs.btrfs --force "${root_part}"
# Mount the root partition to /mnt
mount "${root_part}" /mnt
# Create btrfs subvolumes
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@var
# Remount with btrfs options
umount -R /mnt
btrfs_opts="defaults,x-mount.mkdir,compress=lzo,ssd,noatime,nodiratime"
mount -t btrfs -o subvol=@,"${btrfs_opts}" "${root_part}" /mnt
mount -t btrfs -o subvol=@home,"${btrfs_opts}" "${root_part}" /mnt/home
mount -t btrfs -o subvol=@var,"${btrfs_opts}" "${root_part}" /mnt/var
mount -t btrfs -o subvol=@snapshots,"${btrfs_opts}" "${root_part}" /mnt/.snapshots

boot_part="${DISK}1"
# Format the boot partition
mkfs.fat -F32 "${boot_part}"
# Mount the boot partition
mount -o "defaults,x-mount.mkdir" "${boot_part}" /mnt/boot

# Generate hardware-configuration.nix
nixos-generate-config --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix /home/nixos/nixos-config/system/x86_64-linux/vlw-test-001/hardware-configuration.nix -f
rm /mnt/etc/nixos/configuration.nix /mnt/etc/nixos/hardware-configuration.nix

# Run installation from nixOS with #flake
nixos-install --flake .#vlw-test-001