{
  description = "NixOS Configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11-small";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    hardware.url = "github:NixOS/nixos-hardware/master";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs-unstable.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, hardware, disko, ... }
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