{
  modulesPath,
  lib,
  config,
  pkgs,
  venikx-site,
  kevinthebard-site,
  ...
}@args:
let
  domainName = "venikx.com";
  photographyDomainName = "kevinthebard.com";

  imaginaryAddr = "127.0.0.1:8088";
  sourceFolderAddr = "127.0.0.1:8889";

  imaginaryProxy = site: ''
    rewrite "^.+/(?P<img_width>[0-9]+)/(?P<img_file>.*)$" /resize?width=$img_width&url=http://${sourceFolderAddr}/${site}/$img_file$img_type break;

    proxy_pass http://${imaginaryAddr};

    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;

    proxy_cache images;
    proxy_cache_key "$host$uri$is_args$args$img_type";
    proxy_cache_valid 200 24h;
  '';
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
      "${photographyDomainName}" = {
        group = config.services.nginx.group;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    config.services.nginx.defaultHTTPListenPort
    config.services.nginx.defaultSSLListenPort
  ];

  services.nginx = {
    enable = true;

    virtualHosts."${photographyDomainName}" = {
      root = kevinthebard-site.packages.${pkgs.system}.default;
      forceSSL = true;
      useACMEHost = "${photographyDomainName}";
      extraConfig = ''
        limit_req zone=general burst=20 nodelay;
        error_page 404 /404.html;
      '';

      locations."/images/" = {
        extraConfig = imaginaryProxy "kevinthebard";
      };
    };

    virtualHosts."${domainName}" = {
      root = venikx-site.packages.${pkgs.system}.default;
      forceSSL = true;
      useACMEHost = "${domainName}";
      extraConfig = ''
        limit_req zone=general burst=20 nodelay;
      '';

      locations."/images/" = {
        extraConfig = imaginaryProxy "kevinthebard";
      };
    };

    virtualHosts."status.${domainName}" = {
      forceSSL = true;
      useACMEHost = "${domainName}";
      extraConfig = ''
        limit_req zone=general burst=20 nodelay;
      '';
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.gatus.settings.web.port}";
          recommendedProxySettings = true;
        };
      };
    };

    appendHttpConfig = ''
      map $uri $img_type {
        default "";
        "~*\.webp$" "&type=webp";
        "~*\.jpe?g$" "&type=jpeg";
        "~*\.png$" "&type=png";
      }

      map $uri $uri_base {
        "~^(.+)\.[^.]+$" $1;
        default $uri;
      }

      proxy_cache_path /var/cache/nginx/images
        levels=1:2
        keys_zone=images:50m
        inactive=24h
        max_size=10g;

      server {
        listen ${sourceFolderAddr};
        root /srv/cdn;

        location / {
          try_files $uri $uri_base.jpg $uri_base.jpeg $uri_base.png $uri_base.webp =404;
        }
      }
    '';

  };

  services.imaginary = {
    enable = true;
    address = "127.0.0.1";
    port = 8088;
    settings = {
      return-size = true;
      concurrency = 8;
      enable-url-source = true;
      allowed-origins = "http://${sourceFolderAddr}";
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
    homeMode = "750";
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
