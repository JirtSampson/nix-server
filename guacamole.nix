{ self, config, lib, pkgs, ... }:
{
  nixpkgs.overlays = [
    # freerdp overlay
    (final: prev: {
      freerdp = prev.freerdp.overrideAttrs (finalAttrs: previousAttrs: {
        patches = [
          (prev.fetchpatch2 {
            url = "https://github.com/FreeRDP/FreeRDP/commit/67fabc34dce7aa3543e152f78cb4ea88ac9d1244.patch";
            hash = "sha256-kYCEjH1kXZJbg2sN6YNhh+y19HTTCaC7neof8DTKZ/8=";
          })
        ];

        postPatch =
          ''
            # skip NIB file generation on darwin
            substituteInPlace "client/Mac/CMakeLists.txt" "client/Mac/cli/CMakeLists.txt" \
              --replace-fail "if(NOT IS_XCODE)" "if(FALSE)"

            substituteInPlace "libfreerdp/freerdp.pc.in" \
              --replace-fail "Requires:" "Requires: @WINPR_PKG_CONFIG_FILENAME@"

            substituteInPlace client/SDL/SDL2/dialogs/{sdl_input.cpp,sdl_select.cpp,sdl_widget.cpp,sdl_widget.hpp} \
              --replace-fail "<SDL_ttf.h>" "<SDL2/SDL_ttf.h>"
          ''
          + prev.lib.optionalString (prev.pcsclite != null) ''
            substituteInPlace "winpr/libwinpr/smartcard/smartcard_pcsc.c" \
              --replace-fail "libpcsclite.so" "${prev.lib.getLib prev.pcsclite}/lib/libpcsclite.so"
          '';

        nativeBuildInputs = previousAttrs.nativeBuildInputs ++ [
          prev.writableTmpDirAsHomeHook
        ];
      });
    })

    # guacamole-server overlay
    (final: prev: {
      guacamole-server = prev.guacamole-server.overrideAttrs (finalAttrs: previousAttrs: {
        src = prev.fetchFromGitHub {
          owner = "apache";
          repo = "guacamole-server";
          rev = "acb69735359d4d4a08f65d6eb0bde2a0da08f751";
          hash = "sha256-rqGSQD9EYlK1E6y/3EzynRmBWJOZBrC324zVvt7c2vM=";
        };

        patches = [];
      });
    })
  ];

  environment.systemPackages = with pkgs; [
    freerdp
  ];

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "databahn@gmx.com";
      dnsProvider = "cloudflare";
      environmentFile = "/var/lib/secrets/certs.secret";
    };
  };

  services = {
    guacamole-server = {
      enable = true;
      host = "127.0.0.1";
      port = 4822;
      userMappingXml = "/var/tomcat/secrets/guac.secret";
      package = pkgs.guacamole-server;
    };
    
    guacamole-client = {
      enable = true;
      enableWebserver = true;
      settings = {
        guacd-port = 4822;
        guacd-hostname = "localhost";
      };
    };

    tomcat = {
      enable = true;
      port = 8091;
    };
    
    nginx.virtualHosts = {
      "guac.databahn.network" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        locations."/guacamole/" = {
          proxyPass = "http://127.0.0.1:8091/guacamole/";
          extraConfig = ''
            proxy_buffering off;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $http_connection;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';
        };
        locations."/" = {
          return = "301 https://$host/guacamole/";
        };
      };
    };
  };
}
