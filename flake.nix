{
  description = "Personal CLI tools and Neovim for macOS and Ubuntu";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      systems = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
      forEachSystem = nixpkgs.lib.genAttrs systems;
      # Local account and checkout details are read from the environment. Package inputs
      # stay pinned in flake.lock. setup-home.sh supplies these with --impure.
      mkHome = system:
        let
          username = builtins.getEnv "DEV_CONFIG_USERNAME";
          homeDirectory = builtins.getEnv "DEV_CONFIG_HOME";
          checkout = builtins.getEnv "DEV_CONFIG_CHECKOUT";
        in
        if username == "" || homeDirectory == "" || checkout == "" then
          throw "Run scripts/setup-home.sh to supply the current account and checkout, or set DEV_CONFIG_USERNAME, DEV_CONFIG_HOME, and DEV_CONFIG_CHECKOUT and evaluate with --impure."
        else if !(nixpkgs.lib.hasPrefix "/" checkout) then
          throw "DEV_CONFIG_CHECKOUT must be an absolute checkout path."
        else home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = { inherit checkout; };
          modules = [
            ./home.nix
            {
              home.username = username;
              home.homeDirectory = homeDirectory;
            }
          ];
        };
    in {
      homeConfigurations = {
        macos = mkHome "aarch64-darwin";
        ubuntu = mkHome "x86_64-linux";
        ubuntu-arm64 = mkHome "aarch64-linux";
      };

      packages = forEachSystem (system: {
        home-manager = home-manager.packages.${system}.home-manager;
      });

      # Optional trial environment; everyday tools are installed by Home Manager.
      devShells = forEachSystem (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.mkShell {
            packages = import ./nix/packages.nix { inherit pkgs; };
          };
        });
    };
}
