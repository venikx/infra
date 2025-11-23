{ lib, pkgs, config, ... }: {

  imports = [ ../all.nix ./disko-config.nix ./hardware-configuration.nix ];
  system.stateVersion = "24.11";

  boot = {
    tmp.cleanOnBoot = true;
    loader.grub = {
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
  };

  networking = { hostName = "vm-prod-media-01"; };

  # graphs
  services.grafana.enable = true;
  services.prometheus.enable = true;
  services.loki.enable = true;

  # media
  services.calibre-web.enable = true;
  services.syncthing.enable = true;
  modules.services.immich.enable = true;

  environment.systemPackages = [ pkgs.cifs-utils pkgs.samba ];
  fileSystems = let nasIP = "172.19.20.10";
  in {
    "/mnt/nas/entertainment" = {
      device = "${nasIP}:/mnt/tank/entertainment";
      fsType = "nfs";
      options = [ "x-systemd.automount" "noauto" ];
    };
    "/mnt/nas/documents" = {
      device = "//${nasIP}/documents";
      fsType = "cifs";
      options = [
        "credentials=/etc/nixos/smb-secrets"
        "vers=3.0"
        "x-systemd.automount"
        "x-systemd.requires=network-online.target"
        "x-systemd.after=network-online.target"
        "uid=${toString config.users.users.syncthing.uid}"
        "gid=${toString config.users.groups.syncthing.gid}"
      ];
    };
  };
}
