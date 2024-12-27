_: {
  boot = {
    initrd = {
      availableKernelModules = [
        "nvme"
        "sd_mod"
        "sdhci_pci"
        "usb_storage"
        "usbhid"
        "xhci_pci"
      ];
      kernelModules = [ ];
    };

    kernelModules = [
      "vhost_vsock"
    ];

    kernel = {
      sysctl = {
        "fs.inotify.max_user_watches" = 524288;
      };
    };
    initrd.systemd.enable = true;

    kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      #supportedFilesystems = ["btrfs"];
    };
  };
}
