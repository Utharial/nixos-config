{
  description = "NixOS Configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11-small";

    hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    lanzaboote.url = "github:nix-community/lanzaboote";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";

  };

  outputs = { self, nixpkgs, hardware, ... }
  @inputs: {
    # Create nixosConfiguration for different systems
    nixosConfigurations = {
      # Desktop
      # Headless
      VLW-Test-001 = lib.mk {
        system = "x86_64-linux";
      };

      # You can define more machines here.
    };
  };
}