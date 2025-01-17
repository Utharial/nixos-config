{
  inputs = {
    # Nix pkg channels
    nixpkgs.url = "github:NixOs/nixpkgs/nixos-unstable";

    # Nix hardware config
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Secure boot option with TPM or Yubikey unlock
/*     lanzaboote = {
      url = github:nix-community/lanzaboote;
      inputs.nixpkgs.follows = "nixpkgs";
    }; */

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, nixos-hardware, ... }
  @ inputs: let
    inherit (self) outputs;

      stateVersion = "24.11";
      username = "ark";

      libx = import ./lib {
        inherit
          self
          inputs
          outputs
          stateVersion
          username
          ;
      };
  in {

    nixosConfigurations = {
      vlw-test-001 = libx.mkHost {
        hostname = "vlw-test-001";
        environment.systemPackages = [
              # For debugging and troubleshooting Secure Boot.
              pkgs.sbctl
            ];
      };
      /* setup-secureboot = nixpkgs.lib.nixosSystem {
        modules = [
          # This is not a complete NixOS configuration and you need to reference
          # your normal configuration here.

          #lanzaboote.nixosModules.lanzaboote

          ({ pkgs, lib, ... }: {

            environment.systemPackages = [
              # For debugging and troubleshooting Secure Boot.
              pkgs.sbctl
            ];

            # Lanzaboote currently replaces the systemd-boot module.
            # This setting is usually set to true in configuration.nix
            # generated at installation time. So we force it to false
            # for now.
            boot.loader.systemd-boot.enable = lib.mkForce false;

            /* boot.lanzaboote = {
              enable = true;
              pkiBundle = "/var/lib/sbctl";
            }; */
          })
        ];
      }; */
    };
  };
}