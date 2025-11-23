{ config, lib, pkgs, ... }:

{
  containers.ttrss = {
    privateNetwork = true;
    hostAddress = "10.251.0.1";
    localAddress = "10.251.0.2";
    autoStart = true;
    forwardPorts = [{
      containerPort = 80;
      hostPort = 8002;
    }];
    bindMounts = {
      "/etc/resolv.conf" = {
        hostPath = "/etc/resolv.conf";
        isReadOnly = true;
      };
    };
    config = { config, pkgs, ... }:
      let ttrssConfig = config.services.tt-rss;
      in {
        systemd.services."tt-rss-init" = {
          serviceConfig = {
            Type = "oneshot";
            User = "${ttrssConfig.user}";
          };
          script = "${pkgs.php}/bin/php ${ttrssConfig.root}/www/update.php --update-schema=force-yes";
          after = [ "tt-rss.service" ];
          wantedBy = [ "multi-user.target" ];
        };

        services.tt-rss = {
          enable = true;
          selfUrlPath = "http://192.168.1.197:8002";
        };

        services.postgresql = {
          enable = true;
          enableTCPIP = true;
          package = pkgs.postgresql_12;
        };

        networking.firewall.allowedTCPPorts = [ 80 ];
      };
  };
}
