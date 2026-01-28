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

  # Beszel Hub (server/dashboard)
  systemd.services.beszel-hub = {
    description = "Beszel monitoring hub";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    
    serviceConfig = {
      ExecStart = "${pkgs.beszel}/bin/beszel-hub serve --http 127.0.0.1:8090";
      Restart = "always";
      User = "beszel";
      Group = "beszel";
      StateDirectory = "beszel-hub";
      WorkingDirectory = "/var/lib/beszel-hub";
    };
  };

  # Beszel Agent (collects metrics)
  systemd.services.beszel-agent = {
    description = "Beszel monitoring agent";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    
    serviceConfig = {
      EnvironmentFile = "/var/lib/secrets/beszel-agent.env";
      ExecStart = "${pkgs.beszel}/bin/beszel-agent";
      Restart = "always";
      User = "beszel";
      Group = "beszel";
      StateDirectory = "beszel-agent";
      WorkingDirectory = "/var/lib/beszel-agent";
    };
  };

  users.users.beszel = {
    isSystemUser = true;
    group = "beszel";
    home = "/var/lib/beszel";
  };

  users.groups.beszel = {};

  services.nginx.virtualHosts = {
    "status.databahn.network" = {
      forceSSL = true;
      enableACME = true;
      acmeRoot = null;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8090";
        proxyWebsockets = true;
      };
    };
  };
}
