{ config, lib, pkgs, ... }:

{
  users.groups.media = { };
  services.sabnzbd = {
    openFirewall = lib.mkDefault config.services.sabnzbd.enable;
    group = "media";
    #configFile = ./sabnzbd.ini
  };

  services.nginx = lib.mkIf config.services.sabnzbd.enable {
    enable = true;
    virtualHosts."_" = {
      locations."/sabnzbd" = { proxyPass = "http://127.0.0.1:8080"; };
    };
  };
}
