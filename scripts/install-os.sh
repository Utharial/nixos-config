#!/usr/bin/env bash

set -euo pipefail
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

TARGET_HOST="${1:-}"

if [ "$(id -u)" != 0 ]; then
  echo "ERROR! $(basename "${0}") should be run as a regular user"
  exit 1
fi

if [[ -z "$TARGET_HOST" ]]; then
    echo "ERROR! $(basename "${0}") requires a hostname as the first argument"
    exit 1
fi

if [ ! -e "system/x86_64-linux/${TARGET_HOST}/base/disks.nix" ]; then
  echo "ERROR! $(basename "${0}") could not find the required system/x86_64-linux/${TARGET_HOST}/base/disks.nix"
  exit 1
fi

# Check if the machine we're provisioning expects a keyfile to unlock a disk.
# If it does, generate a new key, and write to a known location.
if grep -q "root.keyfile" "system/x86_64-linux/${TARGET_HOST}/base/disks.nix"; then
  #echo -n "$(head -c32 /dev/random | base64)" > /tmp/root.keyfile
  echo -n "$(head -c1 /dev/random | base64)" > /tmp/root.keyfile
fi

echo "WARNING! The disks in ${TARGET_HOST} are about to get wiped"
echo "         NixOS will be re-installed"
echo "         This is a destructive operation"
echo
read -p "Are you sure? [y/N]" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    nix run github:nix-community/disko \
       --experimental-features "nix-command flakes" \
       -- \
       --mode zap_create_mount \
        "system/x86_64-linux/${TARGET_HOST}/base/disks.nix"

    # Generate hardware-configuration.nix and copy to our working directory
    nixos-generate-config --root /mnt
    cp /mnt/etc/nixos/hardware-configuration.nix /home/nixos/nixos-config/system/x86_64-linux/${TARGET_HOST}/base/hardware-configuration.nix -f
    rm /mnt/etc/nixos/configuration.nix /mnt/etc/nixos/hardware-configuration.nix

    nixos-install --flake ".#${TARGET_HOST}"

    # Make needed scripts exectubale
    chmod +x scripts/setup-secureboot.sh
    chmod +x scripts/update-os.sh

    # Rsync my nix-config to the target install
    rsync -a --delete "${DIR}/.." "/mnt/root/nixos-config"

    # If there is a keyfile for a data disk, put copy it to the root partition and
    # ensure the permissions are set appropriately.
    if [[ -f "/tmp/root.keyfile" ]]; then
      cp /tmp/root.keyfile /mnt/etc/root.keyfile
      read -p "WARNING! Save up the Key to unlock the systemdrive at startup, press any key to continune" -n 1 -r
      #echo "WARNING! Save up the Key to unlock the systemdrive at startup"
      echo $(cat /mnt/etc/root.keyfile)
      systemd-cryptenroll --tpm2-device=auto  --unlock-key-file=/mnt/etc/root.keyfile /dev/sda2
      chmod 0400 /mnt/etc/root.keyfile
    fi  
    reboot
fi