{ self, config, lib, pkgs, ... }:
{
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "databahn@gmx.com";
      dnsProvider = "cloudflare";
      environmentFile = "/var/lib/secrets/certs.secret";
    };
  };

  services = {
    nginx.virtualHosts = {
      "papers.databahn.network" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          proxyPass = "http://127.0.0.1:28981";
          proxyWebsockets = true;
        };
      };
    };
    
    paperless = {
      enable = true;
      port = 28981;
      address = "127.0.0.1";
      passwordFile = "/var/lib/secrets/paperless-password";
      settings = {
        PAPERLESS_OCR_LANGUAGE = "eng";
        PAPERLESS_ADMIN_USER = "admin";
        PAPERLESS_TRUSTED_PROXIES = "127.0.0.1";
        PAPERLESS_URL = "https://papers.databahn.network";
      };
    };

    # FTP server for scanner uploads
    vsftpd = {
      enable = true;
      writeEnable = true;
      localUsers = true;
      userlist = [ "scanner" ];
      userlistEnable = true;
      localRoot = "/var/lib/paperless/consume";
      extraConfig = ''
        pasv_enable=YES
        pasv_min_port=51000
        pasv_max_port=51999
        allow_writeable_chroot=YES
        local_umask=002
        file_open_mode=0660
      '';
    };
  };

  # Create scanner user with access to paperless consume directory
  users.users.scanner = {
    isNormalUser = true;
    home = "/var/lib/paperless/consume";
    createHome = false;
    group = "paperless";
  };

  # Ensure the consume directory has correct permissions
  systemd.tmpfiles.rules = [
    "d /var/lib/paperless/consume 0775 paperless paperless -"
  ];

  # Open FTP ports in firewall
  networking.firewall = {
    allowedTCPPorts = [ 21 ];
    allowedTCPPortRanges = [
      { from = 51000; to = 51999; }  # Passive FTP ports
    ];
  };

  environment.systemPackages = [
    pkgs.paperless-ngx
  ];
}
