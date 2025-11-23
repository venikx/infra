{ ... }: {

  imports = [ ../all.nix ./hardware-configuration.nix ./wireguard.nix ];

  networking = { hostName = "chakra"; };

  services.tailscale.enable = false;
  services.prometheus.exporters.node.enable = true;
  services.promtail.enable = true;

  system.stateVersion = "23.11";
}
