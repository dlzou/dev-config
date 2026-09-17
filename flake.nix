{
  description = "Neovim development environment for Python and C/C++";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { nixpkgs, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forEachSystem = nixpkgs.lib.genAttrs systems;
    in {
      devShells = forEachSystem (system:
        let pkgs = import nixpkgs { inherit system; };
        in {
          default =
            assert pkgs.lib.versionAtLeast pkgs.neovim.version "0.12.0";
            assert pkgs.lib.versionAtLeast pkgs.tree-sitter.version "0.26.1";
            assert pkgs.lib.versionAtLeast pkgs.ruff.version "0.5.3";
            pkgs.mkShell {
              packages = with pkgs; [
                neovim basedpyright ruff clang-tools
                ripgrep fd tree-sitter yazi file
                git gnumake gcc curl gnutar gzip unzip
              ];
            };
        });
    };
}
