{ pkgs, lib, ... }: {
  modules = [
    lanzaboote.nixosModules.lanzaboote
  ];
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    #pkiBundle = "/etc/secureboot";
    pkiBundle = "/var/lib/sbctl";
  };
  #
  environment.systemPackages = with pkgs; [
    sbctl  # for key management
  ];
}