{ bin, ... }:
{
  

    fileSystems = {
    "/".device = lib.mkForce "/dev/disk/by-partlabel/root";
    "/boot".device = lib.mkForce "/dev/disk/by-partlabel/ESP";
    "/.snapshots".device = lib.mkForce "/dev/disk/by-partlabel/root";
    "/home".device = lib.mkForce "/dev/disk/by-partlabel/root";
    "/nix".device = lib.mkForce "/dev/disk/by-partlabel/root";
    "/var".device = lib.mkForce "/dev/disk/by-partlabel/root";
  };

  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              start = "1M";
              end = "128M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f"
                              "-LNixOS" # Filesystem label
                  ]; # Override existing partition
                  # Subvolumes must set a mountpoint in order to be mounted,
                  # unless their parent is mounted
                  subvolumes =
                    let
                      commonOptions = [
                        "compress=zstd"
                        "noatime"
                        "nodiscard" # Prefer periodic TRIM
                      ];
                    in
                    {
                      # Root subvolume
                      "/@" = {
                        mountpoint = "/";
                        mountOptions = commonOptions;
                      };

                      # Persistent data
                      "/@persist" = {
                        mountpoint = "/persist";
                        mountOptions = commonOptions ++ [
                          "nodev"
                          "nosuid"
                          "noexec"
                        ];
                      };

                      # User home directories
                      "/@home" = {
                        mountpoint = "/home";
                        mountOptions = commonOptions ++ [
                          "nodev"
                          "nosuid"
                        ];
                      };

                      # Nix data, including the store
                      "/@nix" = {
                        mountpoint = "/nix";
                        mountOptions = commonOptions ++ [
                          "nodev"
                          "nosuid"
                        ];
                      };

                      # System logs
                      "/@log" = {
                        mountpoint = "/var/log";
                        mountOptions = commonOptions ++ [
                          "nodev"
                          "nosuid"
                          "noexec"
                        ];
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

/* {
  disko.devices = {
    disk = {
      nvme0n1 = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              label = "boot";
              name = "ESP";
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                ];
              };
            };
            luks = {
              size = "100%";
              label = "luks";
              content = {
                type = "luks";
                name = "cryptroot";
                extraOpenArgs = [
                  "--allow-discards"
                  "--perf-no_read_workqueue"
                  "--perf-no_write_workqueue"
                ];
                # https://0pointer.net/blog/unlocking-luks2-volumes-with-tpm2-fido2-pkcs11-security-hardware-on-systemd-248.html
                settings = {crypttabExtraOpts = ["fido2-device=auto" "token-timeout=10"];};
                content = {
                  type = "btrfs";
                  extraArgs = ["-L" "nixos" "-f"];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = ["subvol=root" "compress=zstd" "noatime"];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = ["subvol=home" "compress=zstd" "noatime"];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = ["subvol=nix" "compress=zstd" "noatime"];
                    };
                    "/persist" = {
                      mountpoint = "/persist";
                      mountOptions = ["subvol=persist" "compress=zstd" "noatime"];
                    };
                    "/log" = {
                      mountpoint = "/var/log";
                      mountOptions = ["subvol=log" "compress=zstd" "noatime"];
                    };
                    "/swap" = {
                      mountpoint = "/swap";
                      swap.swapfile.size = "64G";
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

  fileSystems."/persist".neededForBoot = true;
  fileSystems."/var/log".neededForBoot = true;
}
 */