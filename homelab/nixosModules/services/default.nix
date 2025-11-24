{ config, lib, ... }:

{
  imports = [
    ./audiobookshelf.nix
    ./calibre-web.nix
    ./homepage.nix
  ];

  networking.firewall.allowedTCPPorts = lib.mkIf config.services.caddy.enable [
    80
    443
  ];

  services.caddy.virtualHosts = {
    "homelab.local".extraConfig = ''
      tls internal
    '';
  };
}
