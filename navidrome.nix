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
      "music.databahn.network" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          proxyPass = "http://127.0.0.1:4533";
      };
    };
  };

    navidrome = {
      enable = true;
      openFirewall = true;
      settings = {
        MusicFolder = "/mnt/Media/Music";
        Backup.Path =  "/mnt/Media/Music/Navidrome";
        Backup.Count = 3;
        Backup.Schedule = "0 18 * * *";
        };
   };
 };
}
