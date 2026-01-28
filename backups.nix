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

  environment.systemPackages = [ pkgs.backrest pkgs.restic ];

  systemd.tmpfiles.rules = [
    "d /var/lib/backrest 0750 root root -"
    "d /var/lib/backrest/data 0750 root root -"
    "d /var/lib/backrest/config 0750 root root -"
  ];

  # Backrest server
  systemd.services.backrest = {
    description = "Backrest Backup Manager";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.backrest}/bin/backrest -bind-address 127.0.0.1:9898 -config-file /var/lib/backrest/config/config.json -data-dir /var/lib/backrest/data";
      Restart = "on-failure";
      RestartSec = "10s";
      # Run as root to access all files for backup
      User = "root";
      Group = "root";
    };

    environment = {
      HOME = "/var/lib/backrest";
      BACKREST_RESTIC_COMMAND = "${pkgs.restic}/bin/restic";
    };
  };

  services.nginx.virtualHosts = {
    "backups.databahn.network" = {
      forceSSL = true;
      enableACME = true;
      acmeRoot = null;
      locations."/" = {
        proxyPass = "http://127.0.0.1:9898";
        proxyWebsockets = true;
      };
      extraConfig = ''
        client_max_body_size 0;
        proxy_request_buffering off;
      '';
    };
  };
}
