{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ../modules/system.nix
    ../modules/security.nix
    ../modules/access.nix
  ];

  time.timeZone = lib.mkDefault "Europe/Helsinki";
  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = with pkgs; [
    coreutils
    pciutils
    git
    neovim
    curl
  ];

  services.openssh = {
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
        # probably need something like this
        #text = config.age.secrets.server1SshHostKey.path; # decrypted via agenix
      }
    ];
  };
}
