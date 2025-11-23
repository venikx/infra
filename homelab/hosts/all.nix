{
  config,
  pkgs,
  lib,
  ...
}:

{
  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
  nixpkgs.config.allowUnfree = true;

  time.timeZone = lib.mkDefault "Europe/Helsinki";
  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = with pkgs; [
    coreutils
    pciutils
    git
    neovim
    wget
    curl
  ];

  networking.firewall.enable = true;

  services.openssh = {
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
    enable = true;
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAILuO3IAkKZEo//ta325nJCrUgt6clBCswIQihlj1EpydAAAABHNzaDo= code@venikx.com"
  ];
}
