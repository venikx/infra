{ ... }:

{
  services.prometheus.exporters.node = {
    enabledCollectors = [ "systemd" ];
    listenAddress = "127.0.0.1";
    port = 9101;
    openFirewall = true;
  };
}
