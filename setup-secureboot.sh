#!/usr/bin/env bash

set -euo pipefail
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Create Secureboot keys
sbctl create-keys

# Enroll keys to tpm chip include with microsoft keys
sbctl enroll-keys --microsoft

# Check if we need to sign boot files
VERIFY="$(sbctl verify)>&1"

# if verify not empty, sign boot files
if [[ -n "$VERIFY" ]]; then
    for ITEM in $VERIFY; do
        [[ ${ITEM} =~ (/boot/EFI/[A-Za-z]*/[A-Za-z0-9-].*.[EFIefi]*) ]] && OUTPUT=${BASH_REMATCH} || OUTPUT=
        
        if [[ -n $OUTPUT ]]; then
            sbctl sign $OUTPUT
        fi
    done
fi

# Activate TPM2 autounlock 
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+1+7 /dev/sda2