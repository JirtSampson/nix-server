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

# Open firewall for MQTT and Music Assistant
 networking.firewall = {
  allowedTCPPorts = [ 1883 8095 ]; # Added 8095 for Music Assistant
};

 services = {
    #nginx.commonHttpConfig = ''
    #  log_format debug_format '$remote_addr - $remote_user [$time_local] '
    #                       '"$request" $status $body_bytes_sent '
    #                       '"$http_referer" "$http_user_agent" '
    #                       'rt=$request_time uct="$upstream_connect_time" '
    #                       'uht="$upstream_header_time" urt="$upstream_response_time"';
    #'';
    nginx.virtualHosts = {
      "ha.databahn.network" = {
        forceSSL = true;
        enableACME = true;
        extraConfig = ''
          proxy_buffering off;
         '';
        acmeRoot = null;
        locations."/" = {
          proxyPass = "http://localhost:8123";
          proxyWebsockets = true;
          #extraConfig = ''
          #  '';
      };
        # Add a specific location for websocket connections
        locations."/api/websocket" = {
        proxyPass = "http://127.0.0.1:8123/api/websocket";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
        '';
        };
      };
    };

    mosquitto = {
      enable = true;
      listeners = [
        {
          acl = [ "pattern readwrite #" ];
          omitPasswordAuth = true;
          settings.allow_anonymous = true;
        }
      ];
    };

    home-assistant = {
      enable = true;
      configDir = "/var/lib/hass/config";
      # Add HACS support
      package = (pkgs.home-assistant.override {
        extraPackages = ps: with ps; [
          # Add any Python dependencies needed for HACS
          setuptools
        ];
      });
      extraComponents = [
        "default_config"
        "esphome"
        "met"
        "radio_browser"
        "spotify"
        "starlink"
        "ecobee"
        "homekit"
        "homekit_controller"
        "epson"
        "emulated_kasa"
        "tplink"
        "emulated_roku"
        "opengarage"
        "roku"
        "opnsense"
        "zha"
        "ipp"
        "mqtt"
        "plex"
        "obihai"
        "ollama"
        "github"
      ];
      config = {
        default_config = {};
        http = {
          server_host = [ "0.0.0.0" ];
          trusted_proxies = [ "127.0.0.1" ];
          use_x_forwarded_for = true;
        };

        # Frontend themes
        frontend = {
          themes = "!include_dir_merge_named themes";
        };
  
        # Text to speech
        tts = [
          {
            platform = "google_translate";
          }
        ];
        # Include files for automation, scripts, and scenes
        automation = "!include automations.yaml";
        script = "!include scripts.yaml";
        scene = "!include scenes.yaml"; 
        # Notification configuration
        notify = [
          {
            name = "email_chris_and_megan";
            platform = "smtp";
            sender = "databahn@gmx.com";
            recipient = [
              "`cat /var/lib/secrets/m-email.secret`"
              "`cat /var/lib/secrets/c-email.secret`"
            ];
            username = "databahn@gmx.com";
            password = "`cat /var/lib/secrets/mailpass.secret`";
            server = "mail.gmx.com";
          }
        ];
  
        # Shell commands
        shell_command = {
          roku_intermission = "curl -X POST http://192.168.1.23:8060/launch/837?contentId=3tAfYSnrykQ&mediaType=live";
          roku_classical = "curl -X POST http://192.168.1.23:8060/launch/837?contentId=VThrx5MRJXA&mediaType=live";
          roku_home = "curl -X POST http://192.168.1.23:8060/keypress/home";
        };
        # Plex Recently Added configuration
        sensor = [
          {
            platform = "plex_recently_added";
            token = "!secret plex_token";
            host = "192.168.1.9";
            port = 32400;
            ssl = false;
            max = 44444;
            section_types = [ "movie" "show" ];
            download_images = true;
         }
       ];
       # Enable more detailed logging
       logger = {
         default = "info";
         logs = {
           "custom_components.plex_recently_added" = "debug";
           "homeassistant.components.sensor" = "debug";
           "custom_components.upcoming_media_card" = "debug";
         };
       };  
     };
   };
 };
}
