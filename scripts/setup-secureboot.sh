#!/run/current-system/sw/bin/sh

set -euo pipefail
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Check if sbctl keys are needed
SBCTLSTATUS="$(sbctl status)>&1"

DISK="$(grep -Eio "/dev/[a-zA-Z0-9]*" "home/${USER}/${HOSTNAME}/base/disks.nix")"

if ! [[ ${SBCTLSTATUS} =~ (sbctl is installed) ]]; then
    # Create Secureboot keys
    sbctl create-keys

    # Enroll keys to tpm chip include with microsoft keys
    sbctl enroll-keys --microsoft
fi

# Check if we need to sign boot files
VERIFY="$(sbctl verify)>&1"

# if verify is not signed, sign boot files
if [[ ${VERIFY} =~ (is not signed) ]]; then
    for ITEM in $VERIFY; do
        [[ ${ITEM} =~ (/boot/EFI/[A-Za-z]*/[A-Za-z0-9-].*.[EFIefi]*) ]] && OUTPUT=${BASH_REMATCH} || OUTPUT=
        
        if [[ -n $OUTPUT ]]; then
            sbctl sign $OUTPUT
        fi
    done
    systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=0 --unlock-key-file=/etc/root.keyfile ${DISK}2
    reboot
else
    # Activate TPM2 autounlock 
    systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=0+1+7 --unlock-key-file=/etc/root.keyfile ${DISK}2
fi