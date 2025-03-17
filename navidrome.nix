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
      Backup.Path = "/mnt/Media/Music/Navidrome";
      Backup.Count = 3;
      Backup.Schedule = "0 18 * **";
      LastFM.ApiKey = "$LASTFM_API_KEY";
      LastFM.Secret = "$LASTFM_SECRET";
      Spotify.ID = "$SPOTIFY_ID";
      Spotify.Secret = "$SPOTIFY_SECRET";
      EnableTranscodingConfig = true;
     };
   };
 };
  # Add appropriate permissions for the secrets file
  systemd.services.navidrome.serviceConfig = {
    EnvironmentFile = "/var/lib/secrets/navidrome.env";
  };
}
