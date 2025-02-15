{pkgs, lib, inputs, hostname, username, ...}: {
	imports = [
		inputs.disko.nixosModules.disko
		../../common
		./hardware-configuration.nix
		./systemd-timer.nix
	];
	
	networking = {
		hostName = hostname;
		useDHCP = lib.mkDefault true;
	};

	users.users = {
		ark = {
			isNormalUser = true;
			mutableUsers = true;
			home = "/home/ark";
			extraGroups = [ "wheel" ];
			openssh.authorizedKeys.keys = [
				"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICe0qxF6g+aGx/VjCEGhJBue/urSRQFcSXs3QV8fT0WI username"
			];
		};
	};

	
	  # List services that you want to enable:
	
	  # Open ports in the firewall.
	  # networking.firewall.allowedTCPPorts = [ ... ];
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
