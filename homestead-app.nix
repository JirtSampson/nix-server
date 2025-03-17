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
          proxyPass = "http://127.0.0.1:3000";
        };
      };
    };
  };
}
