# file: configuration.nix
{ pkgs, lib, ... }:
let
    sources = import ./npins;
    proxmox-nixos = import sources.proxmox-nixos;
in
{
  imports = [ proxmox-nixos.nixosModules.proxmox-ve ];

  services.proxmox-ve = {
    enable = true;
    ipAddress = "192.168.1.20";
  };

  nixpkgs.overlays = [
    proxmox-nixos.overlays.x86_64-linux
  ];

  # The rest of your configuration...
}
