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
  };
  outputs = { self, nixpkgs, nixos-hardware, ... }
  @ inputs: let
    inherit (self) outputs;
    systems = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    packages =
      forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    nixosConfigurations = {
      vlw-test-001 = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./system/x86_64-linux/vlw-test-001
          inputs.disko.nixosModules.disko
        ];
      };
    };
  };
}