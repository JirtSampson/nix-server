# Auto-generated using compose2nix v0.3.1-pre.
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
        "auth.databahn.network" = {
          forceSSL = true;
          enableACME = true;
          acmeRoot = null;
          locations."/" = {
            proxyPass = "http://127.0.0.1:9000";
            proxyWebsockets = true;
          };
        };
      };
    };
}

# Compose2nix version is not currently function, and a nix module does not exist. 
# Current implementation uses docker-compose.yml in /home/nix/docker/authentik for now.
# This is just for an SSL proxy

