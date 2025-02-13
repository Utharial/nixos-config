{ pkgs, ...} : {
  systemd.timers = {
    "enable-secureboot" = {
      wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "1s";
          Unit = "enable-secureboot.service";
        };
    };
  };

  systemd.services = {
    "enable-secureboot" = {
      enable = true;
      path = [
        pkgs.sbctl
        pkgs.systemd
        pkgs.util-linux
      ];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        ExecStart = "/root/nixos-config/scripts/setup-secureboot_part1.sh";
      };
    };
  };
}