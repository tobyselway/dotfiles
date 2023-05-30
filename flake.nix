{

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, hyprland, nix-vscode-extensions, ... }@inputs: {

    nixosConfigurations.studio = nixpkgs.lib.nixosSystem rec {

      system = "x86_64-linux";

      specialArgs = { inherit inputs hyprland nix-vscode-extensions; };

      modules = [
        ./configuration.nix

        home-manager.nixosModules.home-manager

        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs hyprland nix-vscode-extensions; };
          home-manager.users.toby.imports = [
            hyprland.homeManagerModules.default
            ./home.nix
          ];
        }
      ];

    };

  };

}
