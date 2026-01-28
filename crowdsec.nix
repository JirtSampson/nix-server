{ config, pkgs, lib, ... }:

{
  services.crowdsec = {
    enable = true;
    
    settings = {
      lapi = {
        credentialsFile = "/var/lib/crowdsec/data/local_api_credentials.yaml";
      };
      
      capi = {
        credentialsFile = "/var/lib/crowdsec/data/capi_credentials.yaml";
      };
      
      general = {
        api = {
          server = {
            enable = true;
            listen_uri = "127.0.0.1:8081";
          };
        };
      };
    };
    
    hub = {
      collections = [
        "crowdsecurity/nginx"
        "crowdsecurity/linux"
        "crowdsecurity/sshd"
      ];
    };
    
    localConfig.acquisitions = [
      {
        source = "file";
        filenames = [ "/var/log/nginx/access.log" ];
        labels.type = "nginx";
      }
      {
        source = "journalctl";
        journalctl_filter = [ "_SYSTEMD_UNIT=sshd.service" ];
        labels.type = "syslog";
      }
    ];
  };

  services.crowdsec-firewall-bouncer = {
    enable = true;
    registerBouncer.enable = false;
    secrets.apiKeyPath = "/var/lib/secrets/crowdsec-bouncer-key";
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/crowdsec/data 0750 crowdsec crowdsec -"
  ];
}
