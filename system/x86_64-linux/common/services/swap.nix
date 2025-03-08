{ pkgs, ... } : { 
  # Use btrfs mkswapfile to create the swapfile
  systemd.services.create-swapfile = {
    description = "Create and configure Btrfs swapfile";
    wantedBy = [ "multi-user.target" ];
    before = [ "swap.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = [
        "${pkgs.bash}/bin/bash -c 'if [ ! -f /swap/swapfile ]; then ${pkgs.btrfs-progs}/bin/btrfs filesystem mkswapfile --size 16g /swap/swapfile; fi'"
        "${pkgs.coreutils}/bin/chmod 600 /swap/swapfile"
        # No need for chattr +C or compression=none, as mkswapfile handles CoW
      ];
    };
  };
}