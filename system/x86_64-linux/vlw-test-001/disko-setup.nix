{ pkgs, self, ... }:
let
  dependencies = [
    self.nixosConfigurations.${host}.config.system.build.toplevel
    self.nixosConfigurations.${host}.config.system.build.diskoScript
    self.nixosConfigurations.${host}.config.system.build.diskoScript.drvPath
    self.nixosConfigurations.${host}.pkgs.stdenv.drvPath

    # https://github.com/NixOS/nixpkgs/blob/f2fd33a198a58c4f3d53213f01432e4d88474956/nixos/modules/system/activation/top-level.nix#L342
    self.nixosConfigurations.${host}.pkgs.perlPackages.ConfigIniFiles
    self.nixosConfigurations.${host}.pkgs.perlPackages.FileSlurp

    (self.nixosConfigurations.${host}.pkgs.closureInfo { rootPaths = [ ]; }).drvPath
  ] ++ builtins.map (i: i.outPath) (builtins.attrValues self.inputs);

  closureInfo = pkgs.closureInfo { rootPaths = dependencies; };
in
# Now add `closureInfo` to your NixOS installer
{
  environment.etc."install-closure".source = "${closureInfo}/store-paths";

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "install-nixos-unattended" ''
      set -eux
      # Replace "/dev/disk/by-id/some-disk-id" with your actual disk ID
      exec ${pkgs.disko}/bin/disko-install --flake "${self}#${host}" --disk my-disk "/dev/sda"
    '')
  ];
}