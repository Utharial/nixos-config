{
  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, disko, nixpkgs }: {
    nixosConfigurations.i7 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ pkgs, ... }:
        let
          dependencies = [
            pkgs.stdenv.drvPath
            self.nixosConfigurations.nixos.config.system.build.toplevel
            self.nixosConfigurations.nixos.config.system.build.diskoScript
          ] ++ builtins.map (i: i.outPath) (builtins.attrValues self.inputs);

          closureInfo = pkgs.closureInfo { rootPaths = dependencies; };
        in
        {
          environment.etc."install-closure".source = "${closureInfo}/store-paths";

          environment.systemPackages = [
            (pkgs.writeShellScriptBin "install-nixos-unattended" ''
              set -eux
              # Replace "/dev/disk/by-id/some-disk-id" with your actual disk ID
              exec ${pkgs.disko}/bin/disko-install --flake "${self}#nixos" --disk vdb /dev/sda "$@"
            '')
          ];
        })

      ];
    };

    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {
          boot.loader.systemd-boot.enable = true;
          imports = [ self.inputs.disko.nixosModules.disko ];
          disko.devices = {
            disk = {
              vdb = {
                device = "/dev/disk/by-id/some-disk-id";
                type = "disk";
                content = {
                  type = "gpt";
                  partitions = {
                    ESP = {
                      type = "EF00";
                      size = "500M";
                      content = {
                        type = "filesystem";
                        format = "vfat";
                        mountpoint = "/boot";
                      };
                    };
                    root = {
                      size = "100%";
                      content = {
                        type = "filesystem";
                        format = "ext4";
                        mountpoint = "/";
                      };
                    };
                  };
                };
              };
            };
          };
        }
      ];
    };

  };
}