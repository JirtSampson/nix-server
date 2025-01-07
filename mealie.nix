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
 
 networking.firewall.allowedTCPPorts = [ 9056 ];
 services = {
    mealie = {
      enable = true;
      port = 9056;
    };
    nginx.virtualHosts = {
      "mealie.databahn.network" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          proxyPass = "http://127.0.0.1:9056";
          proxyWebsockets = true;
        };
      };
    };
  };
}
