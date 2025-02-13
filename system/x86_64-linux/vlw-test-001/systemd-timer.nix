{ pkgs, ...} : {
  systemd.timers = {
    "enable-secureboot" = {
      wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "1s";
          Unit = "enable-secureboot.service";
        };
    };
    "update-os" = {
      wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar=weekly;
          Unit = "update-os.service";
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
        ExecStart = "/root/nixos-config/scripts/setup-secureboot.sh";
      };
    };
    "upate-os" = {
      enable = true;
      path = [
        pkgs.sbctl
        pkgs.systemd
        pkgs.util-linux
      ];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        ExecStart = "/root/nixos-config/scripts/update-os.sh";
      };
    };
  };
}