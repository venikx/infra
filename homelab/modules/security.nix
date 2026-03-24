{ lib, ... }:

{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  networking.firewall = {
    enable = true;
    allowPing = false;
  };

  services.avahi.enable = false;
  services.printing.enable = false;
  services.fail2ban.enable = lib.mkDefault true;
}
