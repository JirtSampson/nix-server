{ config, lib, pkgs, ... }:

{
  networking.firewall = {
    allowedTCPPorts = [ 8080 8443 6789 8880 8843 ];
    allowedUDPPorts = [ 3478 10001 ];
  };
}
