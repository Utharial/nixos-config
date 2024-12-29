{
  inputs = {
    # Nix pkg channels
    nixpkgs.url = "github:NixOs/nixpkgs/nixos-24.11-small";

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

      dependencies = [
            pkgs.stdenv.drvPath
            self.nixosConfigurations.nixos.config.system.build.toplevel
            self.nixosConfigurations.nixos.config.system.build.diskoScript
          ] ++ builtins.map (i: i.outPath) (builtins.attrValues self.inputs);

          closureInfo = pkgs.closureInfo { rootPaths = dependencies; };
  in {

  environment.etc."install-closure".source = "${closureInfo}/store-paths";

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "install-nixos-unattended" ''
      set -eux
      # Replace "/dev/disk/by-id/some-disk-id" with your actual disk ID
      exec ${pkgs.disko}/bin/disko-install --flake "${self}#${hostname}" --disk my-disk "/dev/sda"
    '')
  ];

    nixosConfigurations = {
      vlw-test-001 = libx.mkHost {
        hostname = "vlw-test-001";
      };
    };
  };
}