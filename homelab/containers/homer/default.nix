{ config, lib, pkgs, ... }:

{
  config.virtualisation.oci-containers = {
    containers = {
      homer = {
        user = "1001:100";
        image = "b4bz/homer";
        ports = ["8000:8080"];
        volumes = [
          "/home/venikx/homelab/containers/homer/assets/:/www/assets"
        ];
      };
    };
  };
}
