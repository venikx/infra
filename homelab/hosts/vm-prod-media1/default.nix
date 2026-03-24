{
  lib,
  pkgs,
  config,
  ...
}:
{

  imports = [
    ../../profiles/deprecated.nix
    ./disko-config.nix
    ./hardware-configuration.nix
  ];
  system.stateVersion = "25.05";

  boot = {
    tmp.cleanOnBoot = true;
    loader.grub = {
      # no need to set devices, disko will add all devices that have a EF02 partition to the list already
      # devices = [ ];
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
  };

  age.rekey = {
    hostPubkey = "";
    storageMode = "local";
    masterIdentities = [ "/home/venikx/.ssh/agenix-rekey-thick-yubikey.txt" ];
    localStorageDir = ./. + "/secrets/rekeyed/${config.networking.hostName}";
  };

  networking = {
    hostName = "vm-prod-media1";
    hosts = {
      "172.19.20.10" = [ "truenas.local" ];
    };
  };

  services.caddy.enable = true;
  services.homepage-dashboard.enable = true;

  # graphs
  #services.grafana.enable = true;
  #services.prometheus.enable = true;
  #services.loki.enable = true;

  # media
  services.calibre-web.enable = true;
  services.audiobookshelf.enable = true;
  services.immich.enable = true;

  fileSystems = {
    "/mnt/nas/entertainment" = {
      device = "truenas.local:/mnt/tank/entertainment";
      fsType = "nfs";
      options = [
        "x-systemd.automount"
        "noauto"
        "x-systemd.requires=network-online.target"
        "x-systemd.after=network-online.target"
      ];
    };
  };
}
