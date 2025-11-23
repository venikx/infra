{ config, lib, ... }:

{
  services.grafana = {
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 9000;
        domain = "172.19.20.247";
      };
    };
  };

  services.nginx = lib.mkIf config.services.grafana.enable {
    enable = true;
    virtualHosts."_" = {
      locations."/" = {
        proxyPass =
          "http://${config.services.grafana.settings.server.http_addr}:${
            toString config.services.grafana.settings.server.http_port
          }";
        recommendedProxySettings = true;
        proxyWebsockets = true;
      };
    };
  };

  networking.firewall.allowedTCPPorts = lib.mkIf config.services.grafana.enable
    [ config.services.grafana.settings.server.http_port ];
}
