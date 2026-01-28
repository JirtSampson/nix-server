{ config, pkgs, lib, ... }: {
  virtualisation.docker.enable = true;

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      scrypted = {
        image = "ghcr.io/koush/scrypted:latest";
        autoStart = true;
        volumes = [
          "/var/lib/scrypted:/server/volume"
          "/mnt/spare-ssd/cctv:/recordings"
        ];
        environment = {
          SCRYPTED_WEBHOOK_UPDATE_AUTHORIZATION = "Bearer";
          SCRYPTED_WEBHOOK_UPDATE = "http://localhost:10444/v1/update";
        };
        extraOptions = [
          "--network=host"
          
        ];
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "databahn@gmx.com";
      dnsProvider = "cloudflare";
      environmentFile = "/var/lib/secrets/certs.secret";
    };
  };

  services.nginx.virtualHosts = {
    "cams.databahn.network" = {
      forceSSL = true;
      enableACME = true;
      acmeRoot = null;
      locations."/" = {
        proxyPass = "https://127.0.0.1:10443";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_ssl_verify off;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
    };
  };

  networking.firewall = {
    allowedTCPPorts = [
      10443  # Scrypted HTTPS web interface
      11080  # Scrypted HTTP web interface
      1883   # MQTT
    ];
  };

  environment.systemPackages = with pkgs; [
    ffmpeg
  ];

  # Create storage directories
  systemd.tmpfiles.rules = [
    "d /var/lib/scrypted 0755 root root -"
    "d /mnt/spare-ssd/cctv 0755 root root -"
  ];
}
