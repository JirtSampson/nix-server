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
    vikunja = {
       enable = true;
       frontendScheme = "https";
       frontendHostname = "tasks.databahn.network";
       
       # Mail configuration
       settings = {
         mailer = {
           enabled = true;
           host = "mail.gmx.com";  # GMX SMTP server
           port = 587;
           authtype = "plain";
           username = "databahn@gmx.com";
           # Password will be loaded from environment variable
           fromemail = "databahn@gmx.com";
           skiptlsverify = false;
           forcessl = false;
           queuelength = 100;
           queuetimeout = 30;
         };
         
         service = {
           enableemailreminders = true;
         };
         
         # Enable mail logging for debugging
         log = {
           mail = "stdout";
           maillevel = "DEBUG";
         };
       };
    };

    nginx.virtualHosts = {
      "tasks.databahn.network" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          proxyPass = "http://[::1]:3456";
          proxyWebsockets = true;
        };
        extraConfig ="";           
      };
    };
 };

 # Add environment file to the systemd service
 systemd.services.vikunja.serviceConfig.EnvironmentFile = "/var/lib/secrets/vikunja.env";
}
