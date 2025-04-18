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
      "lubelogger.databahn.network" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          proxyPass = "http://localhost:8223/";
          proxyWebsockets = true;
          };
      };
    };
  };

# Auto-generated using compose2nix v0.2.1-pre.
# Runtime
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
  virtualisation.oci-containers.backend = "docker";

  # Containers
  virtualisation.oci-containers.containers."lubelogger" = {
    image = "ghcr.io/hargata/lubelogger:latest";
    environment = {
      LANG = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
      LOGGING__LOGLEVEL__DEFAULT = "Error";
      MailConfig__EmailFrom = "lubelogger@gmx.com";
      MailConfig__EmailServer = "mail.gmx.com";
      MailConfig__Port = "587";
      MailConfig__Username = "databahn@gmx.com";
    };
    environmentFiles = [
      "/var/lib/secrets/lubelogger.env"
    ];
    volumes = [
      "/mnt/docker/lubelogger/config:/App/config:rw"
      "/mnt/docker/lubelogger/data:/App/data:rw"
      "/mnt/docker/lubelogger/documents:/App/wwwroot/documents:rw"
      "/mnt/docker/lubelogger/images:/App/wwwroot/images:rw"
      "/mnt/docker/lubelogger/keys:/root/.aspnet/DataProtection-Keys:rw"
      "/mnt/docker/lubelogger/log:/App/log:rw"
      "/mnt/docker/lubelogger/temp:/App/wwwroot/temp:rw"
      "/mnt/docker/lubelogger/translations:/App/wwwroot/translations:rw"
    ];
    ports = [
      "8223:8080/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=app"
      "--network=lubelogger_default"
    ];
  };
  systemd.services."docker-lubelogger" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
      RestartMaxDelaySec = lib.mkOverride 500 "1m";
      RestartSec = lib.mkOverride 500 "100ms";
      RestartSteps = lib.mkOverride 500 9;
    };
    after = [
      "docker-network-lubelogger_default.service"
    ];
    requires = [
      "docker-network-lubelogger_default.service"
    ];
    partOf = [
      "docker-compose-lubelogger-root.target"
    ];
    wantedBy = [
      "docker-compose-lubelogger-root.target"
    ];
  };

  # Networks
  systemd.services."docker-network-lubelogger_default" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f lubelogger_default";
    };
    script = ''
      docker network inspect lubelogger_default || docker network create lubelogger_default
    '';
    partOf = [ "docker-compose-lubelogger-root.target" ];
    wantedBy = [ "docker-compose-lubelogger-root.target" ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-lubelogger-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
