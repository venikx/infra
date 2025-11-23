{ config, pkgs, ... }:

{
  networking.nat = {
    enable = true;
    enableIPv6 = true;
    externalInterface = "ens3";
    internalInterfaces = [ "wg0" ];
  };

  networking.wg-quick.interfaces = {
    wg0 = {
      address = [ "10.0.0.1/24" "fdc9:281f:04d7:9ee9::1/64" ];
      listenPort = 51820;
      privateKeyFile = "/private/wireguard_key";

      postUp = ''
        ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.0.0.1/24 -o ens3 -j MASQUERADE
        ${pkgs.iptables}/bin/ip6tables -A FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/ip6tables -t nat -A POSTROUTING -s fdc9:281f:04d7:9ee9::1/64 -o ens3 -j MASQUERADE
      '';

      preDown = ''
        ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.0.0.1/24 -o ens3 -j MASQUERADE
        ${pkgs.iptables}/bin/ip6tables -D FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/ip6tables -t nat -D POSTROUTING -s fdc9:281f:04d7:9ee9::1/64 -o ens3 -j MASQUERADE
      '';

      peers = [
        {
          publicKey = "T6bGNe5zvhi1cQhQ+CF8LYlLOqFq2m4+jVj+oYAEuhY=";
          allowedIPs = [ "10.0.0.2/32" "fdc9:281f:04d7:9ee9::2/128" ];
        }
        {
          publicKey = "m82jAn1nkbuhKp6iP4Q9ntCdx66Lm5/tBX+DcYrX7mU=";
          allowedIPs = [ "10.0.0.3/32" "fdc9:281f:04d7:9ee9::3/128" ];
        }
      ];
    };
  };

  services = {
    dnsmasq = {
      enable = true;
      settings = { interface = "wg0"; };
    };
  };

  networking.firewall = {
    allowedUDPPorts =
      [ 53 config.networking.wg-quick.interfaces.wg0.listenPort ];
    allowedTCPPorts = [ 53 ];
    trustedInterfaces = [ "wg0" ];
  };

}
