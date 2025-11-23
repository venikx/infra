{ config, lib, pkgs, ... }:

{
  services.syncthing = {
    overrideDevices = true;
    overrideFolders = true;
    openDefaultPorts = true;
    guiAddress = "172.19.20.247:8384";

    settings = {
      devices = {
        "kevin-iphone" = {
          id =
            "ELIRVGI-W7IUR4D-HRK25JP-HML6LPG-QEH76SY-BTAL4Q6-YO66RTD-SOP37AL";
        };
        "air-nixos" = {
          id =
            "WK7RS2C-362VDSU-6AADX3Q-AFTADBL-PNY3KJO-ALQ6HYO-S6MQMOU-6MSYYAR";
        };
        "earth-nixos" = {
          id =
            "B7PPIHY-MT6I5OM-E3YEC43-FQHTCU4-NBGEOD6-QZGGOVU-EH4RPA3-VE3FVQ7";
        };
      };

      folders = {
        "org" = {
          path = "/mnt/nas/documents/99-org/gtd";
          versioning = {
            type = "simple";
            params.keep = "10";
          };
          devices = [ "kevin-iphone" "air-nixos" "earth-nixos" ];
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 8384 ];
}
