{pkgs, ... } : {
  imports =
    [
      ./base/boot.nix
      ./base/locale.nix
      ./base/packages.nix
      ./services/openssh.nix
    ];
}