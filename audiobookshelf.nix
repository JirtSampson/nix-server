{ self, config, lib, pkgs, ... }:
{

environment.systemPackages = with pkgs; [
  audiobookshelf
];

 security.acme = {
  acceptTerms = true;
  defaults = {
    email = "databahn@gmx.com";
    dnsProvider = "cloudflare";
    environmentFile = "/var/lib/secrets/certs.secret";
    };
  };

 services = {
    audiobookshelf = {
      enable = true;
      port = 8234;
 };
    nginx.virtualHosts = {
      "books.databahn.network" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8234";
          proxyWebsockets = true;
        };
      };
    };
  };
}
