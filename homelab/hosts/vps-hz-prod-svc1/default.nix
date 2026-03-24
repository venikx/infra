{
  modulesPath,
  lib,
  config,
  pkgs,
  venikx-site,
  ...
}@args:
let
  domainName = "venikx.com";
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")

    ../../profiles/base.nix
    ../../modules/nginx.nix
    ./disk-config.nix
    ./hardware-configuration.nix
  ];
  system.stateVersion = "25.05";

  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  security.acme = {
    acceptTerms = true;
    defaults.webroot = "/var/lib/acme/acme-challenge/";
    defaults.email = "late.cart8979@${domainName}";
    certs = {
      "${domainName}" = {
        group = config.services.nginx.group;
        extraDomainNames = [
          "status.${domainName}"
        ];
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    config.services.nginx.defaultHTTPListenPort
    config.services.nginx.defaultSSLListenPort
  ];

  services.nginx = {
    enable = true;
    virtualHosts."${domainName}" = {
      root = venikx-site.packages.${pkgs.system}.default;
      forceSSL = true;
      useACMEHost = "${domainName}";
    };

    virtualHosts."status.${domainName}" = {
      root = "/run/current-system/sw/share/nginx/html";
      forceSSL = true;
      useACMEHost = "${domainName}";
    };
  };

  #age.secrets.secret1.rekeyFile = ../../../secret1.age;
  #services.paperless.enable = true;
  #services.paperless.passwordFile = config.age.secrets.secret1.path;

  age.rekey = {
    hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICSnrzlrR9ow0TiDNkgjWgRJsFfXc7rxffURXnTfpxZ+";
    storageMode = "local";
    masterIdentities = [ "/home/venikx/.ssh/agenix-rekey-thick-yubikey.txt" ];
    localStorageDir = ./. + "/secrets/rekeyed/${config.networking.hostName}";
  };
}
