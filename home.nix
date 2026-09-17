{ config, lib, pkgs, checkout, ... }: {
  # Compatibility baseline for Home Manager defaults; don't bump on routine updates.
  home.stateVersion = "26.05";
  home.packages = import ./nix/packages.nix { inherit pkgs; };
  programs.home-manager.enable = true;
  programs.fzf = {
    enable = true;
    defaultOptions = [ "--height 40%" "--layout=reverse" ];
    # The generated shell.sh owns initialization while startup files stay local.
    enableBashIntegration = false;
    enableZshIntegration = false;
  };
  targets.genericLinux.enable = pkgs.stdenv.hostPlatform.isLinux;
  # This CLI profile must not introduce driver setup or GPU activation checks.
  targets.genericLinux.gpu.enable = false;

  # Shell startup files, Git identity, and credentials stay local.
  programs.bash.enable = false;
  programs.zsh.enable = false;

  xdg.enable = true;
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${checkout}/nvim";
  xdg.configFile."starship.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/starship.toml";
  xdg.configFile."nix/nix.conf".text = ''
    experimental-features = nix-command flakes
  '';

  # Source this once at the end of the existing interactive shell configuration.
  # Absolute paths keep fzf and Starship hooks matched to the selected packages.
  xdg.configFile."dev-config/shell.sh".text = ''
    # Expose the configured profile so verification uses the same location.
    export DEV_CONFIG_PROFILE=${lib.escapeShellArg config.home.profileDirectory}
    if [ -r "$DEV_CONFIG_PROFILE/etc/profile.d/hm-session-vars.sh" ]; then
      . "$DEV_CONFIG_PROFILE/etc/profile.d/hm-session-vars.sh"
    fi
    # A project dev shell should keep its own tools ahead of the personal profile.
    if [ -z "''${IN_NIX_SHELL:-}" ]; then
      case "$PATH" in
        "$DEV_CONFIG_PROFILE/bin"|"$DEV_CONFIG_PROFILE/bin":*) ;;
        *) export PATH="$DEV_CONFIG_PROFILE/bin:$PATH" ;;
      esac
    fi
    case $- in
      *i*)
        if [ -n "''${ZSH_VERSION:-}" ]; then
          eval "$(${config.programs.fzf.package}/bin/fzf --zsh)"
          eval "$(${pkgs.starship}/bin/starship init zsh)"
        elif [ -n "''${BASH_VERSION:-}" ]; then
          eval "$(${config.programs.fzf.package}/bin/fzf --bash)"
          eval "$(${pkgs.starship}/bin/starship init bash)"
        fi
        ;;
    esac
  '';

  home.activation.checkDevConfigCheckout = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    for file in ${lib.escapeShellArg "${checkout}/nvim/init.lua"} ${lib.escapeShellArg "${checkout}/starship.toml"}; do
      if [ ! -f "$file" ]; then
        echo "Missing $file; rerun scripts/setup-home.sh from the current checkout location." >&2
        exit 1
      fi
    done
  '';
}
