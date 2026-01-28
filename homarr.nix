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

  # Nix pkg doesn't exist for Homarr. Using oci-containers to have NixOS wrap the container in a systemd service.
  virtualisation.oci-containers.containers.homarr = {
    image = "ghcr.io/ajnart/homarr:latest";
    ports = [ "127.0.0.1:7575:7575" ];
    volumes = [
      "/var/lib/homarr/configs:/app/data/configs"
      "/var/lib/homarr/icons:/app/public/icons"
      "/var/lib/homarr/data:/data"
    ];
    environment = {
      TZ = "America/New_York";  # Adjust to your timezone
    };
  };

  # Create the data directories
  systemd.tmpfiles.rules = [
    "d /var/lib/homarr 0755 root root -"
    "d /var/lib/homarr/configs 0755 root root -"
    "d /var/lib/homarr/icons 0755 root root -"
    "d /var/lib/homarr/data 0755 root root -"
  ];

  services.nginx.virtualHosts = {
    "home.databahn.network" = {
      forceSSL = true;
      enableACME = true;
      acmeRoot = null;
      locations."/" = {
        proxyPass = "http://127.0.0.1:7575";
        proxyWebsockets = true;
      };
      extraConfig = "";
    };
  };
}
