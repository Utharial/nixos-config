{
  containers.unifi = {
    autoStart = true;
    ephemeral = true;

    # Bind mount for persistent storage
    bindMounts = {
      "/persist/var/lib/unifi" = {
        hostPath = "/var/lib/unifi-data"; # Persistent folder on the host
        isReadOnly = false; # Allow writes to the directory
      };
    };

    config = { config, pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        unifi
      ];

      services.unifi = {
        enable = true;
        openFirewall = true
      };

      networking.firewall = {
        allowedTCPPorts = [ 8080 8443 8880 8843 6789 ];
        allowedUDPPorts = [ 3478 10001 ];
      };
    };
  };
}