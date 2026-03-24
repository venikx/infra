{
  description = "personal infra";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    flake-utils.url = "github:numtide/flake-utils";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    venikx-site.url = "github:venikx/venikx.com";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-hardware,
      flake-utils,
      disko,
      agenix,
      agenix-rekey,
      venikx-site,
    }:
    (flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ agenix-rekey.overlays.default ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.agenix-rekey
            pkgs.age-plugin-yubikey
          ];

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
      agenix-rekey = agenix-rekey.configure {
        userFlake = self;
        nixosConfigurations = self.nixosConfigurations;
        darwinConfigurations = self.darwinConfigurations or { };
      };
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
            agenix.nixosModules.default
            agenix-rekey.nixosModules.default
            ./homelab/hosts/vm-prod-media1
          ];
        };
        vps-hz-prod-svc1 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit venikx-site; };
          modules = [
            disko.nixosModules.disko
            agenix.nixosModules.default
            agenix-rekey.nixosModules.default
            ./homelab/hosts/vps-hz-prod-svc1
          ];
        };
      };
    };
}
