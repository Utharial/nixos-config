{
  systemd.timers = {
    "Enable-SecureBoot" = {
      wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "1s";
          OnUnitActiveSec = "5m";
          Unit = "enable-secureboot.service";
        };
    };
  };

  systemd.services = {
    "enable-secureboot" = {      
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        ExecStart = "/mnt/root/nixos-config/scripts/setup-secureboot_part1.sh";
      };
    };
  };
}