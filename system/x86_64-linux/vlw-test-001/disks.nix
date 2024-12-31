{ lib, ... }:
let
  defaultBtrfsOpts = [
    "defaults"
    "compress=zstd:1"
    "ssd"
    "noatime"
    "nodiratime"
  ];
in
{
  environment.etc = {
    "crypttab".text = ''
      root  /dev/disk/by-partlabel/root  /etc/root.keyfile
    '';
  };

  # TODO: Remove this if/when machine is reinstalled.
  # This is a workaround for the legacy -> gpt tables disko format.
  #fileSystems = {
  #  "/".device = lib.mkForce "/dev/disk/by-partlabel/root";
  #  "/boot".device = lib.mkForce "/dev/disk/by-partlabel/ESP";
  #  "/.snapshots".device = lib.mkForce "/dev/disk/by-partlabel/root";
  #  "/home".device = lib.mkForce "/dev/disk/by-partlabel/root";
  #  "/nix".device = lib.mkForce "/dev/disk/by-partlabel/root";
  #  "/var".device = lib.mkForce "/dev/disk/by-partlabel/root";
  #};

  disko.devices = {
    disk = {
      # 512GB root/boot drive. Configured with:
      # - A FAT32 ESP partition for systemd-boot
      # - Multiple btrfs subvolumes for the installation of nixos
      main = {
        device = "/dev/sda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              start = "0%";
              end = "512MiB";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                # disable settings.keyFile if you want to use interactive password entry
                passwordFile = "/tmp/root.keyfile"; # Interactive
                settings = {
                  allowDiscards = true;
                  keyFile = "/tmp/root.keyfile";
                };
                #additionalKeyFiles = [ "/tmp/additionalSecret.key" ];
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/swap" = {
                      mountpoint = "/.swapvol";
                      swap.swapfile.size = "20M";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}