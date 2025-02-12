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

# Set execution right to run part 2
#chmod +x $DIR/scripts/setup-securebboot_part2.sh

# Create systemd-timer to run part 2
echo "
[Unit]
Description='Setup Secure Boot part 2'

[Service]
ExecStart=$DIR/scripts/setup-securebboot_part2.sh
" > /etc/systemd/system/setup-secureboot_part2.service

echo "
[Unit]
Description="Run helloworld.service 5min after boot and every 24 hours relative to activation time"

[Timer]
OnBootSec=5min
OnUnitActiveSec=24h
OnCalendar=Mon..Fri *-*-* 10:00:*
Unit=helloworld.service

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/setup-secureboot_part2.timer



# Activate TPM2 autounlock 
# sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+1+7 /dev/sda2