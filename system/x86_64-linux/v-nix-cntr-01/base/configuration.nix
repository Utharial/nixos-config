{pkgs, lib, inputs, hostname, username, ...}: {
	imports = [
		inputs.disko.nixosModules.disko
		../../common
		#../containers
		./hardware-configuration.nix
		./systemd-timer.nix
	];
	
	networking = {
		hostName = "v-nix-cntr-01";
		useDHCP = lib.mkDefault true;
    firewall.allowedTCPPorts = [ 8080 8443 8880 8843 6789 ];
    firewall.allowedUDPPorts = [ 3478 10001 ];
	};

	users.users = {
		ark = {
			isNormalUser = true;
			home = "/home/ark";
			extraGroups = [ "wheel" ];
			openssh.authorizedKeys.keys = [
				"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICe0qxF6g+aGx/VjCEGhJBue/urSRQFcSXs3QV8fT0WI username"
			];
		};
	};

	# Define the swapfile (size here is informational; creation is handled by systemd)
  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 8192; 
    }
  ];



	
	  # List services that you want to enable:
	
	  # Open ports in the firewall.
	  # networking.firewall.allowedUDPPorts = [ ... ];
	  # Or disable the firewall altogether.
	  # networking.firewall.enable = false;
	
	  # This value determines the NixOS release from which the default
	  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
	  # this value at the release version of the first install of this system.
	  # Before changing this value read the documentation for this option
	  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
	  system.stateVersion = "24.11"; # Did you read the comment?
	}
