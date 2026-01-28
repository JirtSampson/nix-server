{ config, pkgs, lib, ... }: {
  virtualisation.docker.enable = true;
  
  #virtualisation.oci-containers = {
  #  backend = "docker";
  #  containers = {
  #    neolink = {
  #      image = "quantumentangledandy/neolink";
  #      volumes = [
  #        "/var/lib/secrets/neolink.secret:/etc/neolink.toml:ro"
  #      ];
  #      extraOptions = [
  #        "--network=host"
  #      ];
  #      # Optional: add debug logging
  #      # environment = {
  #      #   RUST_LOG = "debug";
        # };
      #};
    #};
  #};
  services.frigate = {
    enable = true;
    hostname = "cams.databahn.network";
    settings = {
      mqtt = {
        enabled = true;
        host = "localhost";
        topic_prefix = "frigate";
        client_id = "frigate";
      };

      cameras = {
        cam1 = {
          ffmpeg = {
            inputs = [{
              path = "rtsp://192.168.1.174:8554/1";
              roles = ["record"];
            }];
          };
          detect = {
            enabled = false;
          };
          record = {
            enabled = true;
            retain = {
              days = 1;
              mode = "motion";  # Changed to motion-based retention
            };
          };
          motion = {
            threshold = 30;  # Added motion detection threshold
            contour_area = 100;  # Minimum area of motion to trigger recording
          };
        };

        cam2 = {
          ffmpeg = {
            inputs = [{
              path = "rtsp://192.168.1.174:8554/2";
              roles = ["record"];
            }];
          };
          detect = {
            enabled = false;
          };
          record = {
            enabled = true;
            retain = {
              days = 7;
              mode = "motion";
            };
          };
          motion = {
            threshold = 30;
            contour_area = 100;
          };
        };

        cam4 = {
          ffmpeg = {
            inputs = [{
              path = "rtsp://192.168.1.174:8554/4";
              roles = ["record"];
            }];
          };
          detect = {
            enabled = false;
          };
          record = {
            enabled = true;
            retain = {
              days = 7;
              mode = "motion";
            };
          };
          motion = {
            threshold = 30;
            contour_area = 100;
          };
        };

        chicken_cam = {
          ffmpeg = {
            inputs = [{
              path = "rtsp://192.168.1.174:8554/chicken-cam";
              roles = ["record"];
            }];
          };
          detect = {
            enabled = false;
          };
          record = {
            enabled = true;
            retain = {
              days = 2;
              mode = "motion";
            };
          };
          motion = {
            threshold = 30;  # Might want to adjust for chicken movement
            contour_area = 100;
          };
        };

        driveway = {
          ffmpeg = {
            inputs = [{
              path = "rtsp://192.168.1.9:8554/Driveway";
              roles = ["record"];
            }];
          };
          detect = {
            enabled = false;
          };
          record = {
            enabled = true;
            retain = {
              days = 2;
              mode = "motion";
            };
          };
          motion = {
            threshold = 30;  # Might want to adjust for chicken movement
            contour_area = 100;
          };
        };
      
        deck = {
          ffmpeg = {
            inputs = [{
              path = "rtsp://192.168.1.9:8554/Deck";
              roles = ["record"];
            }];
          };
          detect = {
            enabled = false;
          };
          record = {
            enabled = true;
            retain = {
              days = 2;
              mode = "motion";
            };
          };
          motion = {
            threshold = 30;  # Might want to adjust for chicken movement
            contour_area = 100;
          };
        };

        barn = {
          ffmpeg = {
            inputs = [{
              path = "rtsp://192.168.1.9:8554/Barn";
              roles = ["record"];
            }];
          };
          detect = {
            enabled = false;
          };
          record = {
            enabled = true;
            retain = {
              days = 2;
              mode = "motion";
            };
          };
          motion = {
            threshold = 30;  # Might want to adjust for chicken movement
            contour_area = 100;
          };
        };


      };
    };
  };

  # Override environment variables
  systemd.services.frigate.environment = {
    FRIGATE_PORT = "5001";
    FRIGATE_HTTP_HOST = "0.0.0.0";
    FRIGATE_STORAGE_PATH = "/mnt/spare-ssd/cctv";
  };

  networking.firewall = {
    allowedTCPPorts = [
      5001  # Frigate web interface
      1883  # MQTT
      1935  # RTMP
      80    # Proxy
    ];
  };

  environment.systemPackages = with pkgs; [
    ffmpeg
    python3
  ];

  # Update storage directory
  systemd.tmpfiles.rules = [
    "d /mnt/spare-ssd/cctv 0755 frigate frigate -"
  ];
}

