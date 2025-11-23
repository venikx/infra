{ config, lib, pkgs, ... }:

{
  services.prowlarr = {
    openFirewall = lib.mkDefault config.services.prowlarr.enable;
  };

  services.nginx = lib.mkIf config.services.prowlarr.enable {
    enable = true;
    virtualHosts."_" = {
      locations."/prowlarr" = { proxyPass = "http://127.0.0.1:9696"; };
    };
  };
}
