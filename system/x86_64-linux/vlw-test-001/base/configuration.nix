{pkgs, lib, inputs, hostname, ...}: {
	imports = [
		inputs.disko.nixosModules.disko
		../../common
#		../../common/base/boot.nix
#		../../common/base/locale.nix
#		../../common/base/packages.nix
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
			home = "/home/ark";
			extraGroups = [ "wheel" ];
		};
	};

	  	  # networking.hostName = "vlw-test-001"; # Define your hostname.
#	  networking.hostName = hostname;
	  # networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.
	
	  # Configure network proxy if necessary
	  # networking.proxy.default = "http://user:password@proxy:port/";
	  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
	
	  # Enable networking
	#  networking.networkmanager.enable = true;
	

	
	  # List packages installed in system profile. To search, run:
	  # $ nix search wget

	
	  # Some programs need SUID wrappers, can be configured further or are
	  # started in user sessions.
	  # programs.mtr.enable = true;
	  # programs.gnupg.agent = {
	  #   enable = true;
	  #   enableSSHSupport = true;
	  # };
	
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
