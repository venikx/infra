{
  description = "personal infra";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    flake-utils.url = "github:numtide/flake-utils";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-hardware,
      flake-utils,
      disko,
    }:
    (flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages."${system}";
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nodejs_24
            awscli2
          ];

          shellHook = ''
            	    export PATH="$PWD/node_modules/.bin/:$PATH"
            	  '';
        };
      }
    ))
    // {
      nixosConfigurations = {
        # chakra = nixpkgs.lib.nixosSystem {
        #   # vpn
        #   system = "x86_64-linux";
        #   modules = [
        #     ./hosts/chakra
        #     ./nixosModules
        #   ];
        # };

        # mirage = nixpkgs.lib.nixosSystem {
        #   system = "aarch64-linux";
        #   modules = [
        #     ./hosts/mirage
        #     nixos-hardware.nixosModules.raspberry-pi-4
        #     ./nixosModules
        #   ];
        # };
        vm-prod-media1 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./homelab/hosts/vm-prod-media1
            ./homelab/nixosModules
          ];
        };
      };
    };
}
