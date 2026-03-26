{ config, lib, ... }:

{
  networking.firewall.allowedTCPPorts = lib.mkIf config.services.nginx.enable [
    config.services.nginx.defaultHTTPListenPort
    config.services.nginx.defaultSSLListenPort
  ];

  services.nginx = {
    recommendedOptimisation = lib.mkDefault true;
  };
}
