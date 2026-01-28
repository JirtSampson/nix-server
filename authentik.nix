{ self, config, lib, pkgs, ... }:

let
  authentik-nix = builtins.fetchTarball {
    url = "https://github.com/nix-community/authentik-nix/archive/main.tar.gz";
  };
  authentik-compat = import "${authentik-nix}/default.nix";
  # Get the actual package set that has all the components
  authentik-pkgs = authentik-compat.packages.${pkgs.system};
in
{
  imports = [
    "${authentik-nix}/module.nix"
  ];

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "authentik" ];
    ensureUsers = [{
      name = "authentik";
      ensureDBOwnership = true;
    }];
    authentication = pkgs.lib.mkOverride 10 ''
      local all all trust
      host all all 127.0.0.1/32 md5
      host all all ::1/128 md5
    '';
  };

  systemd.services.authentik-db-setup = {
    description = "Set Authentik PostgreSQL password";
    wantedBy = [ "multi-user.target" ];
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      EnvironmentFile = "/var/lib/secrets/authentik.env";
    };
    script = ''
      ${pkgs.postgresql}/bin/psql -U postgres -c "ALTER USER authentik WITH PASSWORD '$AUTHENTIK_POSTGRESQL__PASSWORD';" || true
    '';
  };

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
      "auth.databahn.network" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          proxyPass = "http://127.0.0.1:9000";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $http_host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          '';
        };
      };
    };
    authentik = {
      enable = true;
      environmentFile = "/var/lib/secrets/authentik.env";
      createDatabase = false;
      
      # Pass the entire package set which has all the components the module needs
      authentikComponents = authentik-pkgs;
      
      settings = {
        disable_startup_analytics = true;
        avatars = "initials";
        web.enabled = true;
        listen.http = "0.0.0.0:9000";
        cookie_domain = "databahn.network";
      };
    };
  };
}
