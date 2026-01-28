# Standalone NixOS module file (e.g., smb.nix)
# Import this in your configuration.nix with: imports = [ ./smb.nix ];

{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.samba ];
  # Ensure group with GID 1000 exists for media files
  users.groups.media = {
    gid = 1000;
  };
  services.samba = {
  enable = true;
  openFirewall = true;
  
  settings = {
    global = {
      "workgroup" = "WORKGROUP";
      "server string" = "NixOS Server";
      "netbios name" = "nixserver";
      "security" = "user";
      
      # Network access control
      "hosts allow" = "192.168.0.0/16 127.0.0.1 localhost";
      "hosts deny" = "0.0.0.0/0";
    };
    
    "Music" = {
      "path" = "/mnt/Media/Music";
      "browseable" = "yes";
      "read only" = "no";
      "valid users" = "samba";
      "create mask" = "0777";
      "directory mask" = "0755";
      
      # Force all operations to run as a specific user
      "force user" = "nix";
      "force group" = "media";
    };
  };
};

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };
}
