{ lib, pkgs, config, ... }: {

  imports = [ ../all.nix ./hardware-configuration.nix ./wireguard.nix ];

  networking = { hostName = "mirage"; };

  time.timeZone = "Europe/Helsinki";
  i18n.defaultLocale = "en_US.UTF-8";

  # NOTE(Kevin): Tailscale doesn't seem to allow internet going through the
  # Wireguard tunnel
  # services.tailscale.enable = true;
  services.grafana.enable = true;
  services.prometheus.enable = true;
  services.loki.enable = true;
  services.sabnzbd.enable = true;
  services.radarr.enable = true;
  services.prowlarr.enable = true;
}
