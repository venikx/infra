{ config, lib, ... }:

{
  services.prometheus = {
    listenAddress = "127.0.0.1";
    port = 9001;
    retentionTime = "1y";
    # NOTE(Kevin): By default use node_exporter on the instance which runs the
    # prometheus service to enable self monitoring
    exporters.node.enable = lib.mkDefault config.services.prometheus.enable;

    # TODO(Kevin): I wonder if we can move this config to ./node.nix as it's
    # specific to the node_exporter, but without hardcoding all the ip's.
    # Keeping it here for now.
    scrapeConfigs = [{
      job_name = "nodes";
      static_configs = [{
        targets = [
          #"10.0.0.1:${toString config.services.prometheus.exporters.node.port}"
          #"10.0.0.2:${toString config.services.prometheus.exporters.node.port}"
          # TODO(Kevin): This ain't gonna work without exposing the ports,
          # without having them in the same network config
          "${config.services.prometheus.exporters.node.listenAddress}:${
            toString config.services.prometheus.exporters.node.port
          }"
        ];
      }];
    }];
  };

  services.grafana.provision.enable = true;
  services.grafana.provision.datasources.settings.datasources = [{
    name = "Prometheus";
    type = "prometheus";
    access = "proxy";
    url = "http://${toString config.services.prometheus.listenAddress}:${
        toString config.services.prometheus.port
      }";
  }];

  networking.firewall.allowedTCPPorts =
    lib.mkIf config.services.prometheus.enable
    [ config.services.prometheus.port ];
}
