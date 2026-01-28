# Auto-generated using compose2nix v0.2.1-pre.
{ pkgs, lib, ... }:

{
  # Runtime
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
  virtualisation.oci-containers.backend = "docker";

  # Containers
  virtualisation.oci-containers.containers."unifi_controller" = {
    image = "jacobalberty/unifi:latest";
    environment = {
      DB_NAME = "unifi";
      DB_URI = "mongodb://127.0.0.1/unifi";  # Changed from mongo to 127.0.0.1 since we're using host network
      STATDB_URI = "mongodb://127.0.0.1/unifi_stat";  # Changed from mongo to 127.0.0.1
      TZ = "America/New_York";  # Fixed space in timezone
    };
    volumes = [
      "/home/nix/docker/unifi/backup:/unifi/data/backup:rw"
      "unifi_cert:/unifi/cert:rw"
      "unifi_data:/unifi/data:rw"
      "unifi_dir:/unifi:rw"
      "unifi_init:/unifi/init.d:rw"
      "unifi_log:/unifi/log:rw"
      "unifi_run:/var/run/unifi:rw"
    ];
    # Removed ports section - not needed with host network
    dependsOn = [
      "unifi_mongo"
    ];
    user = "unifi";
    log-driver = "journald";
    extraOptions = [
      "--network=host"  # Changed to host network
      "--sysctl=net.ipv4.ip_unprivileged_port_start=0"
    ];
  };
  systemd.services."docker-unifi_controller" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
      RestartMaxDelaySec = lib.mkOverride 500 "1m";
      RestartSec = lib.mkOverride 500 "100ms";
      RestartSteps = lib.mkOverride 500 9;
    };
    after = [
      "docker-volume-unifi_cert.service"
      "docker-volume-unifi_data.service"
      "docker-volume-unifi_dir.service"
      "docker-volume-unifi_init.service"
      "docker-volume-unifi_log.service"
      "docker-volume-unifi_run.service"
    ];
    requires = [
      "docker-volume-unifi_cert.service"
      "docker-volume-unifi_data.service"
      "docker-volume-unifi_dir.service"
      "docker-volume-unifi_init.service"
      "docker-volume-unifi_log.service"
      "docker-volume-unifi_run.service"
    ];
    partOf = [
      "docker-compose-unifi-root.target"
    ];
    wantedBy = [
      "docker-compose-unifi-root.target"
    ];
  };
  virtualisation.oci-containers.containers."unifi_logs" = {
    image = "bash";
    volumes = [
      "unifi_log:/unifi/log:rw"
    ];
    cmd = [ "bash" "-c" "tail -F /unifi/log/*.log" ];
    dependsOn = [
      "unifi_controller"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=logs"
      "--network=unifi_default"
    ];
  };
  systemd.services."docker-unifi_logs" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
      RestartMaxDelaySec = lib.mkOverride 500 "1m";
      RestartSec = lib.mkOverride 500 "100ms";
      RestartSteps = lib.mkOverride 500 9;
    };
    after = [
      "docker-network-unifi_default.service"
      "docker-volume-unifi_log.service"
    ];
    requires = [
      "docker-network-unifi_default.service"
      "docker-volume-unifi_log.service"
    ];
    partOf = [
      "docker-compose-unifi-root.target"
    ];
    wantedBy = [
      "docker-compose-unifi-root.target"
    ];
  };
  virtualisation.oci-containers.containers."unifi_mongo" = {
    image = "mongo:3.6";
    volumes = [
      "unifi_db:/data/db:rw"
      "unifi_dbcfg:/data/configdb:rw"
    ];
    ports = [
      "127.0.0.1:27017:27017/tcp"  # Expose MongoDB only to localhost
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=mongo"
      "--network=unifi_unifi"
    ];
  };
  systemd.services."docker-unifi_mongo" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
      RestartMaxDelaySec = lib.mkOverride 500 "1m";
      RestartSec = lib.mkOverride 500 "100ms";
      RestartSteps = lib.mkOverride 500 9;
    };
    after = [
      "docker-network-unifi_unifi.service"
      "docker-volume-unifi_db.service"
      "docker-volume-unifi_dbcfg.service"
    ];
    requires = [
      "docker-network-unifi_unifi.service"
      "docker-volume-unifi_db.service"
      "docker-volume-unifi_dbcfg.service"
    ];
    partOf = [
      "docker-compose-unifi-root.target"
    ];
    wantedBy = [
      "docker-compose-unifi-root.target"
    ];
  };

  # Networks
  systemd.services."docker-network-unifi_default" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f unifi_default";
    };
    script = ''
      docker network inspect unifi_default || docker network create unifi_default
    '';
    partOf = [ "docker-compose-unifi-root.target" ];
    wantedBy = [ "docker-compose-unifi-root.target" ];
  };
  systemd.services."docker-network-unifi_unifi" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f unifi_unifi";
    };
    script = ''
      docker network inspect unifi_unifi || docker network create unifi_unifi
    '';
    partOf = [ "docker-compose-unifi-root.target" ];
    wantedBy = [ "docker-compose-unifi-root.target" ];
  };

  # Volumes
  systemd.services."docker-volume-unifi_cert" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect unifi_cert || docker volume create unifi_cert
    '';
    partOf = [ "docker-compose-unifi-root.target" ];
    wantedBy = [ "docker-compose-unifi-root.target" ];
  };
  systemd.services."docker-volume-unifi_data" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect unifi_data || docker volume create unifi_data
    '';
    partOf = [ "docker-compose-unifi-root.target" ];
    wantedBy = [ "docker-compose-unifi-root.target" ];
  };
  systemd.services."docker-volume-unifi_db" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect unifi_db || docker volume create unifi_db
    '';
    partOf = [ "docker-compose-unifi-root.target" ];
    wantedBy = [ "docker-compose-unifi-root.target" ];
  };
  systemd.services."docker-volume-unifi_dbcfg" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect unifi_dbcfg || docker volume create unifi_dbcfg
    '';
    partOf = [ "docker-compose-unifi-root.target" ];
    wantedBy = [ "docker-compose-unifi-root.target" ];
  };
  systemd.services."docker-volume-unifi_dir" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect unifi_dir || docker volume create unifi_dir
    '';
    partOf = [ "docker-compose-unifi-root.target" ];
    wantedBy = [ "docker-compose-unifi-root.target" ];
  };
  systemd.services."docker-volume-unifi_init" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect unifi_init || docker volume create unifi_init
    '';
    partOf = [ "docker-compose-unifi-root.target" ];
    wantedBy = [ "docker-compose-unifi-root.target" ];
  };
  systemd.services."docker-volume-unifi_log" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect unifi_log || docker volume create unifi_log
    '';
    partOf = [ "docker-compose-unifi-root.target" ];
    wantedBy = [ "docker-compose-unifi-root.target" ];
  };
  systemd.services."docker-volume-unifi_run" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect unifi_run || docker volume create unifi_run
    '';
    partOf = [ "docker-compose-unifi-root.target" ];
    wantedBy = [ "docker-compose-unifi-root.target" ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-unifi-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
