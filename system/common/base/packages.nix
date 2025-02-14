# Packages specific for all machines
{ pkgs, ...} : {
  environment.systemPackages = with pkgs; [
    vim
    git
    sbctl
    tmux
    rsync
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}