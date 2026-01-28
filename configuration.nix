# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, pkgs, ... }:
#Use newer unstable packages with an overlay when specified:
let
  unstable = import <nixos-unstable> {
    config = {
      allowUnfree = true;
    };
  };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # Include specific configs for each service we're hosting
      ./nextcloud.nix
      ./immich.nix
#      ./tandoor.nix
      ./mealie.nix
      ./navidrome.nix
      ./audiobookshelf.nix
#      ./plex.nix
      ./vaultwarden.nix
      ./unifi.nix
      ./lubelogger.nix
      ./cf-tunnel.nix
      ./authentik.nix
      ./ha.nix
      ./scrypted.nix
      ./jellyfin.nix
      ./github-webhook.nix
      ./homestead-app.nix
      ./proxmox.nix
      ./vikunja.nix
      ./actualbudget.nix
      ./smb.nix
      ./paperless.nix
      ./guacamole.nix
      ./beszel.nix
      ./homarr.nix
      ./backups.nix
      ./crowdsec.nix
    ];
  
  
  # Increase system-wide file descriptor limits
  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "65536";
    }
    {
      domain = "*";
      type = "hard";
      item = "nofile";
      value = "65536";
    }
  ];
  
  system.copySystemConfiguration = true;
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  
  zramSwap = {
  enable = true;
  algorithm = "lzo";      # zstd is faster
  memoryPercent = 50;      # Use 50% of RAM for zram (adjust as needed)
  priority = 10;           # Higher priority than disk swap
  swapDevices = 1;         # Number of zram devices (1 is recommended)
  };
  networking.hostId= "5ba06ca2";
  # Networking
  networking.extraHosts = ''
  127.0.0.1 office.databahn.network
  127.0.0.1 nextcloud.databahn.network
'';
  networking = {
    hostName = "tiny-server";
    useDHCP = false;
    useNetworkd = true;
  };
security.sudo.wheelNeedsPassword = false;
systemd.network.enable = true;
services.netbird.enable = true;
boot.kernel.sysctl = {
  "net.bridge.bridge-nf-call-iptables" = 0;
  "net.bridge.bridge-nf-call-ip6tables" = 0;
  "net.ipv4.ip_forward" = 1;
};
services.resolved = {
  enable = true;
  dnssec = "allow-downgrade";
  extraConfig = ''
    DNS=192.168.1.2
    FallbackDNS=1.1.1.1 8.8.8.8
  '';
};
systemd.network.netdevs."vmbr0" = {
  netdevConfig = {
    Name = "vmbr0";
    Kind = "bridge";
  };
};
systemd.network.networks = {
  "10-builtin-ethernet" = {
    enable = true;
    name = "enp*";
    DHCP = "no";
    linkConfig.RequiredForOnline = "enslaved";
    networkConfig = {
      Bridge = "vmbr0";
      LinkLocalAddressing = "no";
      DNSDefaultRoute = true;
    };
  };
  "20-bridge" = {
    enable = true;
    name = "vmbr0";
    address = [ "192.168.1.9/24" ];
    gateway = [ "192.168.1.2" ];
    dns = [ "192.168.1.2" ];
    DHCP = "no";
    linkConfig.RequiredForOnline = "routable";
    networkConfig = {
      LinkLocalAddressing = "no";
    };
  };
};
  
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networkmanager enabled incase we want to use the wireless
  # networking.networkmanager.enable = true;
  # Use systemd for networking on the ethernet inferface
  
  # Set your time zone.
  time.timeZone = "America/New_York";
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };
  # Allow uploads of up to 4g for any proxied services
  services.nginx.clientMaxBodySize = "4g";
  # Bluetooth
  hardware.bluetooth.enable = true;
  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };
  
  #Enable VMs and docker
  virtualisation.docker.enable = true;
  
  ## Services
  # SSH
  services.openssh.enable = true;
  services.avahi= {
    enable = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
    extraServiceFiles = {
      homekit = #xml
      ''
      <service-group>
        <name>Home Assistant Bridge</name>
        <service>
          <type>_hap._tcp</type>
          <port>51827</port>
          <txt-record>md=HA Bridge</txt-record>         <!-- friendly name                 -->
          <!-- the following appear to be mandatory -->
          <txt-record>pv=1.0</txt-record>               <!-- HAP version                   -->
          <txt-record>id=67:3F:F0:5D:A8:58</txt-record> <!-- MAC (from `.homekit.state`)   -->
          <txt-record>c#=2</txt-record>                 <!-- config version                -->
          <!-- the following appear to be optional -->
          <txt-record>s#=1</txt-record>                 <!-- accessory state               -->
          <txt-record>ff=0</txt-record>                 <!-- unimportant                   -->
          <txt-record>ci=2</txt-record>                 <!-- accessory category (2=bridge) -->
          <txt-record>sf=1</txt-record>                 <!-- 0=not paired, 1=paired        -->
          <txt-record>sh=UaTxqQ==</txt-record>          <!-- setup hash (used for pairing) -->
        </service>
      </service-group>
    '';
     };
   };
  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nix = {
    isNormalUser = true;
    description = "nix";
    extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd"];
    packages = with pkgs; [];
  };
  users.users.samba = {
    isSystemUser = true;
    description = "Samba-only user for file sharing";
    group = "samba";
    home = "/var/empty";
    createHome = false;
    shell = pkgs.shadow + "/bin/nologin";
  };
  users.groups.samba = {};
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  vim
  git
  wget
  curl
  docker
  docker-compose
  zfs 
  cryptsetup
  msmtp
  mailutils
  libvirt
  virt-manager
  webhook
  openssl
  npins
  wl-clipboard
  killall
  ];
  services.ollama = {
  enable = true;
  package = unstable.ollama; # stable version has bug with tools support needed for HA
  host = "0.0.0.0";
  port = 11434;
  };
  # Configure system-wide mail forwarding
  environment.etc."aliases" = {
    text = ''
      root: `cat /var/lib/secrets/admin-email.secret`
      
      # Common system aliases - all forwarded to root
      MAILER-DAEMON: root
      postmaster: root
      nobody: root
      hostmaster: root
      usenet: root
      news: root
      webmaster: root
      www: root
      ftp: root
      abuse: root
      noc: root
      security: root
    '';
    mode = "0644";
  };
  # Use msmtp for to handle relaying
  programs.msmtp = {
    enable = true;
    setSendmail = true;
    defaults = {
      aliases = "/etc/aliases";
      port = 587;
      tls_trust_file = "/etc/ssl/certs/ca-certificates.crt";
      tls = "on";
      auth = "login";
    };
    accounts = {
      default = {
        host = "mail.gmx.com";
        passwordeval = "cat /var/lib/secrets/mailpass.secret";
        user = "databahn@gmx.com";
        from = "databahn@gmx.com";
      };
    };
  };
 
  # Configure mail command
  environment.etc."mail.rc" = {
    text = ''
      set sendmail="/run/current-system/sw/bin/msmtp -t"
      set sendwait
      set verbose
      set append=yes
    '';
    mode = "0644";
  };
  services.smartd = {
    enable = true;
    notifications.mail.enable = true;
    notifications.test = true;
  };
  
# ZFS disk alerts
  services.zfs.zed.settings = {
    ZED_DEBUG_LOG = "/tmp/zed.debug.log";
    ZED_EMAIL_ADDR = [ "root" ];
    ZED_EMAIL_PROG = "${pkgs.msmtp}/bin/msmtp";
    ZED_EMAIL_OPTS = "@ADDRESS@";
    ZED_NOTIFY_INTERVAL_SECS = 3600;
    ZED_NOTIFY_VERBOSE = true;
    ZED_USE_ENCLOSURE_LEDS = true;
    ZED_SCRUB_AFTER_RESILVER = true;
  };
  # this option does not work; will return error
  services.zfs.zed.enableMail = false;
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  # List services that you want to enable:
  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  # Open ports in the firewall.
   networking.firewall.allowedTCPPorts = [ 443 11434 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
