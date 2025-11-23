{ lib, ... }:

{
  services.fail2ban.enable = lib.mkDefault true;
}
