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
      "nextcloud.databahn.network" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
      };

      "office.databahn.network" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          proxyPass = "http://127.0.0.1:9980";
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_read_timeout 36000s;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "Upgrade";
          '';
        };
      };  
    }; 

    nextcloud = {
      enable = true;
      hostName = "nextcloud.databahn.network";

       # Need to manually increment with every major upgrade.
      package = pkgs.nextcloud30;

      # Let NixOS install and configure the database automatically.
      database.createLocally = true;

      # Let NixOS install and configure Redis caching automatically.
      configureRedis = true;

      # Increase the maximum file upload size to avoid problems uploading videos.
      maxUploadSize = "16G";
      https = true;

      autoUpdateApps.enable = true;
      extraAppsEnable = true;
      extraApps = with config.services.nextcloud.package.packages.apps; {
        # List of apps we want to install and are already packaged in
        # https://github.com/NixOS/nixpkgs/blob/master/pkgs/servers/nextcloud/packages/nextcloud-apps.json
        inherit calendar contacts mail notes richdocuments tasks cookbook deck;
      };

      config = {
        overwriteProtocol = "https";
        defaultPhoneRegion = "PT";
        dbtype = "pgsql";
        adminuser = "admin";
        adminpassFile = "/var/lib/secrets/nextcloud-admin-pass";
      };
      # Suggested by Nextcloud's health check.
      phpOptions."opcache.interned_strings_buffer" = "16";
    };
    # Nightly database backups.
    postgresqlBackup = {
      enable = true;
      startAt = "*-*-* 01:15:00";
    };
  };
  
#Collabora docker container until it's packaged...
   virtualisation.oci-containers.containers = {
    collabora = {
      image = "collabora/code:latest";
      extraOptions = [
        "--dns=192.168.1.2"
      ];
      environment = {
        domain = "office\\.databahn\\.network";
        extra_params = "--o:ssl.enable=false --o:ssl.termination=true";
      };
      environmentFiles = [
        "/var/lib/secrets/collabora.env"
      ];
      ports = [
        "9980:9980"
      ];
    };
  };
}
