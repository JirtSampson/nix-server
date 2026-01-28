# Add to your configuration.nix or a separate module

{ config, lib, pkgs, ... }:

{
 services = {
    nginx.virtualHosts = {
      "farm.databahn.network" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          proxyPass = "http://127.0.0.1:3035";
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $host;
          '';
        };
      };
    };
  };
}
