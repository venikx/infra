{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.audiobookshelf = { };

  services.caddy.virtualHosts = lib.mkIf config.services.audiobookshelf.enable {
    "homelab.local".extraConfig = ''
      handle_path /audiobookshelf* {
        reverse_proxy ${config.services.audiobookshelf.host}:${toString config.services.audiobookshelf.port}
      }
    '';
  };
}
