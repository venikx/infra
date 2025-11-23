{ config, pkgs, lib, ... }:

{
  boot = {
    tmp.cleanOnBoot = true;
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
    "/mnt/nas/entertainment" = {
      device = "192.168.1.182:/mnt/tank/entertainment";
      fsType = "nfs";
      options = [ "x-systemd.automount" "noauto" ];
    };
  };

  hardware.enableRedistributableFirmware = true;

  system.stateVersion = "23.11";
}
