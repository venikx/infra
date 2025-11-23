{ config, lib, pkgs, ... }:

{
  containers.ctest = {
    privateNetwork = true;
    hostAddress = "10.250.0.1";
    localAddress = "10.250.0.2";
    autoStart = true;
    forwardPorts = [{
      containerPort = 80;
      hostPort = 8099;
    }];
    bindMounts = {
      "/etc/resolv.conf" = {
        hostPath = "/etc/resolv.conf";
        isReadOnly = true;
      };
    };
    config = { config, pkgs, ... }:
      {
        services.httpd.enable = true;
        services.httpd.adminAddr = "foo@example.org";
        networking.firewall.allowedTCPPorts = [ 80 ];
      };
  };
}
