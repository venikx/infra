{ ... }:

{
  imports = [
    ./grafana.nix
    ./prometheus.nix
    ./node_exporter.nix
    ./loki.nix
    ./promtail.nix
    ./sabnzbd.nix
    ./prowlarr.nix
    ./radarr.nix
    ./tailscale.nix
    ./services
  ];
}
