{ 
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings.PermitRootLogin = "no";
    allowSFTP = true;
  };
}