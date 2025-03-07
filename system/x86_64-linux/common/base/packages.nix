# Packages specific for all machines
{ pkgs, ...} : {
  environment.systemPackages = with pkgs; [
    vim
    neovim
    git
    sbctl
    tmux
    rsync
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}