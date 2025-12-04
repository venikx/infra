{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.immich = {
    mediaLocation = "/mnt/nas/images/immich";
  };

  users.groups = lib.mkIf config.services.immich.enable {
    photographers.gid = 2000;
  };
  users.users = lib.mkIf config.services.immich.enable {
    immich.extraGroups = [
      "video"
      "render"
      "photographers"
    ];
  };

  services.caddy.virtualHosts = lib.mkIf config.services.immich.enable {
    "immich.homelab.local".extraConfig = ''
      reverse_proxy ${config.services.immich.host}:${toString config.services.immich.port} {
        header_up Host {http.request.host}
        header_up X-Real-IP {http.request.remote_host}
        header_up X-Forwarded-For {http.request.remote_host}
        header_up X-Forwarded-Proto {http.request.scheme}
    '';
  };

  environment.systemPackages = lib.mkIf config.services.immich.enable [
    pkgs.cifs-utils
  ];

  fileSystems."/mnt/nas/images" = lib.mkIf config.services.immich.enable {
    device = "//truenas.local/images";
    fsType = "cifs";
    options = [
      "credentials=/etc/nixos/smb-secrets"
      "vers=3.0"
      "x-systemd.automount"
      "x-systemd.requires=network-online.target"
      "x-systemd.after=network-online.target"
      "uid=993"
      "gid=2000"
      "file_mode=0770"
      "dir_mode=0770"
    ];
  };
}
