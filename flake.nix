{
  inputs = {
    # Nix pkg channels
    nixpkgs.url = "github:NixOs/nixpkgs/nixos-unstable";

    # Nix hardware config
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

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
      };
    };
  };
}