{
  description = "NixOS Configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11-small";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    hardware.url = "github:NixOS/nixos-hardware/master";

/*     home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs"; */

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    lanzaboote.url = "github:nix-community/lanzaboote";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";

  };

  outputs = { self, nixpkgs, hardware, ... }
  @inputs: 
  let
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
    in
    {
    # Create nixosConfiguration for different systems
    nixosConfigurations = {
      # Desktop
      # Headless
      VLW-Test-001 = libx.mkHost {
        hostname = "VLW-Test-001";
      };

      # You can define more machines here.
    };
  };
}