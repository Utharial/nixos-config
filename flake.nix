{
  inputs = {
    # Nix pkg channels
    nixpkgs.url = "github:NixOs/nixpkgs/nixos-24.11";

    # Nix hardware config
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Disko usage for formating and partition
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secure boot option with TPM or Yubikey unlock
    lanzaboote = {
      url = github:nix-community/lanzaboote;
      inputs.nixpkgs.follows = "nixpkgs";
    };


  };
  outputs = { self, nixpkgs, nixos-hardware, lanzaboote, ... }
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