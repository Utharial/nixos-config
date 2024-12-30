#!/usr/bin/env bash

nix --experimental-features 'nix-command flakes' run 'github:nix-community/disko/latest#disko-install' -- --flake .#vlw-test-001 --disk main /dev/sda