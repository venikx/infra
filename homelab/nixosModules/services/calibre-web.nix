{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.calibre-web = {
    listen.ip = "127.0.0.1";
    options = {
      calibreLibrary = "/mnt/nas/entertainment/literature";
      enableBookUploading = true;
      enableBookConversion = true;
    };
  };

  services.caddy.virtualHosts = lib.mkIf config.services.calibre-web.enable {
    "homelab.local".extraConfig = ''
      handle_path /calibre* {
        reverse_proxy ${config.services.calibre-web.listen.ip}:${toString config.services.calibre-web.listen.port} {
          header_up X-Script-Name /calibre
        }
      }
    '';
  };
}
