# Add to your configuration.nix or a separate module

{ config, lib, pkgs, ... }:

{
  # Install webhook package
  environment.systemPackages = with pkgs; [
    webhook
  ];

security.sudo.extraRules = [
  {
    users = [ "webhook" ];
    commands = [
      {
        command = "${pkgs.docker}/bin/docker";
        options = [ "NOPASSWD" ];
      }
      {
        command = "${pkgs.docker-compose}/bin/docker-compose";
        options = [ "NOPASSWD" ];
      }
    ];
  }
]; 

services = {
    nginx.virtualHosts = {
      "ghwhk.databahn.network" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          proxyPass = "http://127.0.0.1:9000";
        };
      };
    };
  };

  # Create the hooks directory and configuration
    environment.etc."webhook/hooks.json".text = ''
    [
      {
        "id": "deploy-rails",
        "execute-command": "/var/deploy/deploy.sh",
        "command-working-directory": "/var/deploy",
        "response-message": "Deploying application...",
        "trigger-rule": {
          "match": {
            "type": "payload-hmac-sha256",
            "secret": "c93462bobby2c-a4is2-4008-9707-a6aadcamummiae119f",
            "parameter": {
              "source": "header",
              "name": "X-Hub-Signature-256"
            }
          }
        }
      }
    ]
  '';
  # Create the systemd service
  systemd.tmpfiles.rules = [
    "d /var/deploy 0750 webhook webhook -"
    "d /var/deploy/homestead 0750 webhook webhook -"
    "f /var/deploy/homestead-deploy.log 0640 webhook webhook -"
  ];
  
  # Set up the Git safe directory on boot
  systemd.services.git-safe-directory = {
    description = "Set up Git safe directory for webhook";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "webhook";
      ExecStart = "${pkgs.git}/bin/git config --global --add safe.directory /var/deploy/homestead";
    };
  };

  systemd.services.webhook = {
    description = "Webhook Service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      ExecStart = "${pkgs.webhook}/bin/webhook -hooks /etc/webhook/hooks.json -verbose -ip '127.0.0.1'";
      Restart = "always";
      User = "webhook";
      Group = "webhook";
      # Add read permission for the secret file
      SupplementaryGroups = [ "secrets" ];
    };
    
    environment = {
      PATH = lib.mkForce (lib.makeBinPath [
        pkgs.bash
        pkgs.coreutils
        pkgs.git
        pkgs.docker
        pkgs.docker-compose
        pkgs.openssh
        pkgs.sudo
        pkgs.rubyPackages.rails
        pkgs.ruby
      ]);
    };


  };
  # Create webhook user and group
  users.users.webhook = {
    isSystemUser = true;
    group = "webhook";
    extraGroups = [ "secrets" ];
    description = "Webhook service user";
    home = "/var/deploy";
    createHome = true;
  };

  users.groups.webhook = {};
  users.groups.secrets = {};

}
