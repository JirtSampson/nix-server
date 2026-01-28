#Proxy only. Configured via docker for now.
{ self, config, lib, pkgs, ... }:
{

services = {
      dashy = {
        enable = true;

 };
    nginx.virtualHosts = {
      "home.databahn.network" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          proxyPass = "https://localhost:8080/";
          proxyWebsockets = true;
            };
      };
    };
  };
}
