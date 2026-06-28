{ config, lib, ... }:

{
  networking.firewall.allowedTCPPorts = lib.mkIf config.services.nginx.enable [
    config.services.nginx.defaultHTTPListenPort
    config.services.nginx.defaultSSLListenPort
  ];

  services.nginx = {
    recommendedOptimisation = lib.mkDefault true;
    appendHttpConfig = ''
      limit_req_zone $binary_remote_addr zone=general:10m rate=10r/s;
    '';
  };
}
