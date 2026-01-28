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
    vikunja = {
       enable = true;
       frontendScheme = "https";
       frontendHostname = "tasks.databahn.network";
       #settings = {
       #  interface = "192.168.1.9:3456";
       #};
    };

    nginx.virtualHosts = {
      "tasks.databahn.network" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          proxyPass = "http://[::1]:3456";
          proxyWebsockets = true;
        };
        extraConfig ="";           
      };
    };
  };
}
