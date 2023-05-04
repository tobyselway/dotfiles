{

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, hyprland, ... }@inputs: {

    nixosConfigurations.studio = nixpkgs.lib.nixosSystem rec {

      system = "x86_64-linux";

      specialArgs = { inherit inputs hyprland; };

      modules = [
        ./configuration.nix

        home-manager.nixosModules.home-manager

        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs hyprland; };
          home-manager.users.toby.imports = [
            hyprland.homeManagerModules.default
            ./home.nix
          ];
        }
      ];

    };

  };

}
