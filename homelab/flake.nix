{
  description = "Homelab";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    flake-utils.url = "github:numtide/flake-utils";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-hardware, flake-utils, disko }:
    (flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages."${system}";
      in {
        devShells.default =
          pkgs.mkShell { packages = with pkgs; [ git-crypt ]; };
      })) // {
        nixosConfigurations = {
          chakra = nixpkgs.lib.nixosSystem { # vpn
            system = "x86_64-linux";
            modules = [ ./hosts/chakra ./nixosModules ];
          };

          mirage = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            modules = [
              ./hosts/mirage
              nixos-hardware.nixosModules.raspberry-pi-4
              ./nixosModules
            ];
          };

          vm-prod-media-01 = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              disko.nixosModules.disko
              ./hosts/vm-prod-media-01
              ./nixosModules
            ];
          };
        };
      };
}
