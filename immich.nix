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
    postgresql.extraPlugins = with pkgs.postgresql.pkgs; [ pgvector ];
    immich = {
      enable = true;
      #host = "127.0.0.1";
      port = 2283;
      mediaLocation = "/mnt/Media/Photos"; 
      settings.server.externalDomain = "https://photoshare.databahn.network";
    };
    immich-public-proxy = {
       enable = true;
       port = 3000;
       immichUrl = "http://[::1]:2283";
       openFirewall = true;
    };

    nginx.virtualHosts = {
      #No host needed for photoshare, that's using cloudflare tunnels directly
      "photos.databahn.network" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          proxyPass = "http://[::1]:2283";
          proxyWebsockets = true;
        };
        extraConfig = ''
          proxy_connect_timeout 600;
          proxy_read_timeout 600;
          proxy_send_timeout 600;
          client_max_body_size 50000M;
          access_log syslog:server=unix:/dev/log,tag=immich;
         '';           
      };
    };
  };
}
