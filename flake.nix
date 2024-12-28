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

/*     dependencies = [
    self.nixosConfigurations.your-machine.config.system.build.toplevel
    self.nixosConfigurations.your-machine.config.system.build.diskoScript
    self.nixosConfigurations.your-machine.config.system.build.diskoScript.drvPath
    self.nixosConfigurations.your-machine.pkgs.stdenv.drvPath

    # https://github.com/NixOS/nixpkgs/blob/f2fd33a198a58c4f3d53213f01432e4d88474956/nixos/modules/system/activation/top-level.nix#L342
    self.nixosConfigurations.your-machine.pkgs.perlPackages.ConfigIniFiles
    self.nixosConfigurations.your-machine.pkgs.perlPackages.FileSlurp */

    #(self.nixosConfigurations.your-machine.pkgs.closureInfo { rootPaths = [ ]; }).drvPath
  #] ++ builtins.map (i: i.outPath) (builtins.attrValues self.inputs);

  #closureInfo = pkgs.closureInfo { rootPaths = dependencies; };
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