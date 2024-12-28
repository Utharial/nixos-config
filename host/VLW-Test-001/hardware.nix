{ inputs, lib, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko

    (import ./disk.nix { inherit lib; })
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
}
