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
    service-name = {
       enable = true;
         };
         
         };

    nginx.virtualHosts = {
      "proxyname.databahn.network" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          proxyPass = "http://127.0.0.1:port";
          proxyWebsockets = true;
        };
        extraConfig ="";           
      };
    };
 };

 # Add environment file to the systemd service
 systemd.services.service-name.serviceConfig.EnvironmentFile = "/var/lib/secrets/secret-name.env";
}
