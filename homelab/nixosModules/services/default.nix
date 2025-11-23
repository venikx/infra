{ config, lib, ... }:

{
  imports = [
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
