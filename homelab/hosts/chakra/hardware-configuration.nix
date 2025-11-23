{ modulesPath, ... }: {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot = {
    tmp.cleanOnBoot = true;
    loader.grub.device = "/dev/vda";
    initrd.availableKernelModules =
      [ "ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi" ];
    initrd.kernelModules = [ "nvme" ];
  };

  fileSystems."/" = {
    device = "/dev/vda1";
    fsType = "ext4";
  };
  swapDevices = [{ device = "/dev/vda2"; }];
  zramSwap.enable = false;
}
