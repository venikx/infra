{ config, lib, ... }:

{
  services.homepage-dashboard = {
    openFirewall = lib.mkIf config.services.homepage-dashboard.enable true;

    settings = {
      title = "Homelab Dashboard";

      layout = {
        Services = {
          style = "row";
          columns = 3;
        };
      };
    };

    services = [
      {
        "Services" = [
          {
            "Homepage" = {
              href = "/";
              description = "Homepage Dashboard";
            };
          }
        ];
      }
    ];

    widgets = [
      {
        datetime = {
          text_size = "xl";
          format = {
            timeStyle = "short";
            dateStyle = "short";
          };
        };
      }
    ];
  };

  services.caddy.virtualHosts = lib.mkIf config.services.homepage-dashboard.enable {
    "homelab.local".extraConfig = ''
      reverse_proxy localhost:${toString config.services.homepage-dashboard.listenPort} {
        header_up Host {http.reverse_proxy.upstream.hostport}
      }
    '';
  };
}
