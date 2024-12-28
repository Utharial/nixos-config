{
  description = "NixOS Configurations";

  inputs = {
    # Import the desired Nix channel. Defaults to unstable, which uses a fully tested rolling release model.
    #   You can find a list of channels at https://wiki.nixos.org/wiki/Channel_branches
    #   To follow a different channel, replace `nixos-unstable` with the channel name, e.g. `nixos-24.05`.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # NixOS hardware settings
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # SecureBoot support
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, hardware, ... }
  @inputs: 
  let
      inherit (self) outputs;
      stateVersion = "24.11";
      username = "ark";

      libx = import ./modules/lib {
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