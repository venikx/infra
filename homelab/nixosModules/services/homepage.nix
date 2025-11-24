{ config, lib, ... }:

{
  services.homepage-dashboard = {

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
          # TODO(venikx): Abstract this into the module itself
          {
            "Calibre Web" = {
              href = "/calibre";
              description = "Digital library management";
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
