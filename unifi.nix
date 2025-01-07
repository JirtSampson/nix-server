#Proxy only. Configured via docker for now.
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
#Commenting this section for now. Doesn't seem to be working via nix pkgs. Using docker for now and will revisit...
#      unifi = {
#        unifiPackage = pkgs.unifi;
#        enable = true;
#        openFirewall = true;
#
#        initialJavaHeapSize = 1024;
#        maximumJavaHeapSize = 1536;        
# };
    nginx.virtualHosts = {
      "unifi.databahn.network" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          proxyPass = "https://localhost:8443/";
          proxyWebsockets = true;
          extraConfig = ''
            # https://community.ui.com/questions/Controller-NGINX-Proxy-login-error/49b64c94-3925-4163-ba33-c1d6206d1fa1#answer/4c9f52e0-d9f1-40a2-9ff7-94223bddd75f
            proxy_set_header Referer "";
            
            proxy_set_header Accept-Encoding "";
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forward-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header Front-End-Https on;
            proxy_redirect off;
            
                    
            proxy_set_header Host $host;
            proxy_set_header Upgrade $http_upgrade;
            # proxy_http_version 1.1;
            proxy_set_header Connection "upgrade";
          '';
            };
      };
    };
  };
}
