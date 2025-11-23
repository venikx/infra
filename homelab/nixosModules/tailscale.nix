{ config, lib, ... }:

{
  networking.firewall.trustedInterfaces =
    lib.mkIf config.services.tailscale.enable [ "tailscale0" ];
}
