# Packages specific for the machine
{ pkgs, ...} : {
  environment.systemPackages = with pkgs; [
  ];
}