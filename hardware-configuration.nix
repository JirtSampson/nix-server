# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "uas" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/b1ff50ac-3049-48b5-80f4-07c034eb6e07";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/7281-3CB8";
      fsType = "vfat";
    };

  fileSystems."/mnt/ssd-spare" =
    { device = "/dev/disk/by-uuid/96fee982-c4af-45e2-a8ba-d35f945e18b9";
      fsType = "btrfs";
    };

#  fileSystems."/data" =
#    { device = "data";
#      fsType = "zfs";
#    };

#  fileSystems."/mnt/data" =
#    { device = "data/encrypted";
#      fsType = "zfs";
#    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/f9b131ec-df3d-4081-ba51-89b6ed300f72"; }
    ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.br-34ff2d3243fd.useDHCP = lib.mkDefault true;
  # networking.interfaces.br-9ff70d57c94e.useDHCP = lib.mkDefault true;
  # networking.interfaces.br-c8c2df0c0016.useDHCP = lib.mkDefault true;
  # networking.interfaces.br-de5508d77774.useDHCP = lib.mkDefault true;
  # networking.interfaces.docker0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp2s0f1.useDHCP = lib.mkDefault true;
  # networking.interfaces.tailscale0.useDHCP = lib.mkDefault true;
  # networking.interfaces.veth037117c.useDHCP = lib.mkDefault true;
  # networking.interfaces.veth7d79ad5.useDHCP = lib.mkDefault true;
  # networking.interfaces.veth9819f65.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp3s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
