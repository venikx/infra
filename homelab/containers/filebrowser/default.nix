{ config, lib, pkgs, ... }:

{
  config.virtualisation.oci-containers = {
    containers = {
      filebrowser = {
        user = "1001:100";
        image = "filebrowser/filebrowser";
        ports = ["8001:8000"];
        volumes = [
          "/home/venikx/:/srv"
          "/home/venikx/homelab/containers/filebrowser/data.db:/database.db"
          "/home/venikx/homelab/containers/filebrowser/settings.json:/.filebrowser.json"
        ];
      };
    };
  };
}
