{ ... }:

{
  imports = [
    ./fail2ban.nix
    ./grafana.nix
    ./prometheus.nix
    ./node_exporter.nix
    ./loki.nix
    ./promtail.nix
    ./nginx.nix
    ./sabnzbd.nix
    ./prowlarr.nix
    ./radarr.nix
    ./tailscale.nix
    ./immich.nix
    ./services
  ];
}
