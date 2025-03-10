{
  containers.unifi = {
    autoStart = true;
    ephemeral = true;

    forwardPorts = [
      { containerPort = 8443; hostPort = 8443; protocol = "tcp"; }
      { containerPort = 8080; hostPort = 8080; protocol = "tcp"; }
      { containerPort = 3478; hostPort = 3478; protocol = "udp"; }
      { containerPort = 10001; hostPort = 10001; protocol = "udp"; }
    ];

    # Bind mount for persistent storage
    bindMounts = {
      "/var/lib/unifi" = {
        hostPath = "/persist/unifi/data";
        isReadOnly = false;
      };
      "/var/db/mongodb" = {
        hostPath = "/persist/unifi/mongodb";
        isReadOnly = false;
      };
      "/var/lib/unifi/backup" = {
        hostPath = "/persist/unifi/backup";
        isReadOnly = false;
      };
    };

    config = { config, pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        unifi
        mongodb
      ];

      # Allow unfree packages
      nixpkgs.config.allowUnfree = true;

      services.unifi = {
        enable = true;
        openFirewall = true;
        mongodbPackage = pkgs.mongodb;
        initialJavaHeapSize = 1024;
        maximumJavaHeapSize = 1024;
      };

      services.mongodb = {
        enable = true;
        bind_ip = "0.0.0.0";
      };

      networking.firewall = {
        allowedTCPPorts = [ 8080 8443 8880 8843 6789 ];
        allowedUDPPorts = [ 3478 10001 ];
      };
    };
  };
}