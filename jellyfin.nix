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
      "jellyfin.databahn.network" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8096";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header X-Forwarded-Host $host;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';
        };
      };
    }; 
    jellyfin.enable = true;
    jellyfin.openFirewall = true;
    };
 environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];
}
