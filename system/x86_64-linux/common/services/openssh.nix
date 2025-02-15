{ 
  services.openssh = {
    enable = true;
    openFirewall = true;
    allowSFTP = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };
}