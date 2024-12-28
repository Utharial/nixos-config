{ inputs, lib, ... }:
{
  imports = [


    (import ./disk.nix { inherit lib; })
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
}
