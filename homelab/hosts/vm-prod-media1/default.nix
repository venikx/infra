{
  lib,
  pkgs,
  config,
  ...
}:
{

  imports = [
    ../all.nix
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

  networking = {
    hostName = "vm-prod-media1";
  };

  services.caddy.enable = true;
  services.homepage-dashboard.enable = true;

  # graphs
  #services.grafana.enable = true;
  #services.prometheus.enable = true;
  #services.loki.enable = true;

  # media
  #services.calibre-web.enable = true;
  #services.syncthing.enable = true;
  #modules.services.immich.enable = true;

  #environment.systemPackages = [
  #  pkgs.cifs-utils
  #  pkgs.samba
  #];
  #fileSystems =
  #  let
  #    nasIP = "172.19.20.10";
  #  in
  #  {
  #    "/mnt/nas/entertainment" = {
  #      device = "${nasIP}:/mnt/tank/entertainment";
  #      fsType = "nfs";
  #      options = [
  #        "x-systemd.automount"
  #        "noauto"
  #      ];
  #    };
  #    "/mnt/nas/documents" = {
  #      device = "//${nasIP}/documents";
  #      fsType = "cifs";
  #      options = [
  #        "credentials=/etc/nixos/smb-secrets"
  #        "vers=3.0"
  #        "x-systemd.automount"
  #        "x-systemd.requires=network-online.target"
  #        "x-systemd.after=network-online.target"
  #        "uid=${toString config.users.users.syncthing.uid}"
  #        "gid=${toString config.users.groups.syncthing.gid}"
  #      ];
  #    };
  #  };
}
