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
    immich = {
      enable = true;
      port = 2283;
      mediaLocation = "/mnt/Media/Photos";
      
      secretsFile = "/var/lib/secrets/immich.env";
      
      settings = {
        server.externalDomain = "https://photos.databahn.network";
        
        oauth = {
          enabled = true;
          issuerUrl = "https://auth.databahn.network/application/o/immich/";
          clientId = "7bMk2fHSxKnhErgvPBULuwoHmZISlQ7TurEHNFpE";
          scope = "openid profile email";
          buttonText = "Login with Authentik";
          autoRegister = true;
          autoLaunch = false;
        };
      };
    };
    
    immich-public-proxy = {
      enable = true;
      port = 3000;
      immichUrl = "http://[::1]:2283";
      openFirewall = true;
    };

    nginx.virtualHosts = {
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
