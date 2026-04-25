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
      forceSSL = true;
      useACMEHost = "${domainName}";
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.gatus.settings.web.port}";
          recommendedProxySettings = true;
        };
      };
    };
  };

  services.gatus = {
    enable = true;
    settings = {
      endpoints = [
        {
          name = "developer-site";
          url = "https://venikx.com";
          interval = "1h";
          conditions = [
            "[STATUS] == 200"
            "[RESPONSE_TIME] < 500"
          ];
        }
        {
          name = "photography-site";
          url = "https://kevinthebard.com";
          interval = "1h";
          conditions = [
            "[STATUS] == 200"
            "[RESPONSE_TIME] < 500"
          ];
        }
      ];
    };
  };

  users.users.cdn-sync = {
    isSystemUser = true;
    group = config.services.nginx.group;
    home = "/srv/cdn";
    createHome = true;
    shell = pkgs.bash;
    openssh.authorizedKeys.keys = [
      ''command="${pkgs.rrsync}/bin/rrsync /srv/cdn",restrict ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDcKD2ZNwTdJr5Tn1iFBQJTMw6m+ABHXXDVy7blAKma2qoZi4gMIsAFY3Z5/BU9Kt/+IDK2flnjFYMP5DeiKburCNOwZSTKZnXRGu+U+KH7px2aS/fLPPP8yvW25gkIab1Fn2LASEySFLdVq3sW0vvWslY+9RTI/3Gnk9h7zxzGbgS5OWaJ7ehcVpb+1dd4r/a5ZkquvQW/hZmsM6l/1d7VTK49oq8BWi/emkn83rhUA/Dy8Xw2+oZm7tqA2D98fJoi+bBZKHavpk588CKNWG9aOnr6VFQPBez6Kvig8qQhWgbLulkydvBuEEFEGOIK6BgrlXwa42p4qmErAnZZ0R938nephlFrZ7GmElGR2WOhfwOh/ySKroKrLHcDl3i0zdqO/fXetdMA8DbxYPNAJVt8MdjByENHA0PzGAq0Uk2re5sk2s3uiKu6H/EBdCclRPbz+FrwuaO0Kd1W4Af2MMD0FvtDR2rR7EgA0LdTQCXnvx76lOZUZ6u0fIe+7BkmIIs= root@truenas''
    ];
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
