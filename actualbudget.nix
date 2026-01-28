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
  actual = {
    enable = true;
    settings = {
      port = 5006;
    };
  };
  nginx.virtualHosts = {
    "nances.databahn.network" = {
      forceSSL = true;
      enableACME = true;
      acmeRoot = null;
      locations."/" = {
        proxyPass = "http://127.0.0.1:5006";
        proxyWebsockets = true;
      };
      extraConfig = ''
        proxy_connect_timeout 600;
        proxy_read_timeout 600;
        proxy_send_timeout 600;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Host $host;
        proxy_redirect http://127.0.0.1:5006 https://nances.databahn.network;
        '';
      };
    };
  };
}
