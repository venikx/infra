{ config, lib, pkgs, ... }:

{
  users.groups.media = { };

  services.radarr = {
    openFirewall = lib.mkDefault config.services.radarr.enable;
    group = "media";
  };

  services.nginx = lib.mkIf config.services.radarr.enable {
    enable = true;
    virtualHosts."_" = {
      locations."/radarr" = { proxyPass = "http://127.0.0.1:7878"; };
    };
  };
}
