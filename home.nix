{ config, lib, pkgs, checkout, ... }:
let
  ghosttyPlatform = if pkgs.stdenv.hostPlatform.isDarwin then "macos" else "ubuntu";
  ghosttyPlatformConfig = "${checkout}/ghostty/${ghosttyPlatform}.ghostty";
in {
  # Compatibility baseline for Home Manager defaults; don't bump on routine updates.
  home.stateVersion = "26.05";
  home.packages = import ./nix/packages.nix { inherit pkgs; };
  programs.home-manager.enable = true;
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
  # Let Nix terminal tools find definitions installed by Ubuntu packages.
  home.sessionSearchVariables = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    TERMINFO_DIRS = [
      "${config.home.profileDirectory}/share/terminfo"
      "/etc/terminfo"
      "/lib/terminfo"
      "/usr/share/terminfo"
    ];
  };
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
  xdg.terminal-exec = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    enable = true;
    settings = {
      default = [ "com.mitchellh.ghostty.desktop" ];
      ubuntu = [ "com.mitchellh.ghostty.desktop" ];
    };
  };
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${checkout}/nvim";
  xdg.configFile."starship.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/starship.toml";
  xdg.configFile."tmux/tmux.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/tmux/tmux.conf";
  xdg.configFile."yazi/yazi.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/yazi/yazi.toml";
  # Load shared settings first, then the platform overrides, directly from the checkout.
  xdg.configFile."ghostty/config.ghostty".text = ''
    config-file = "${checkout}/ghostty/config.ghostty"
    config-file = "${ghosttyPlatformConfig}"
  '';
  xdg.configFile."nix/nix.conf".text = ''
    experimental-features = nix-command flakes
  '';

  # Source from interactive shell startup and Ubuntu's noninteractive login profile.
  # Only interactive shells initialize fzf and Starship below.
  # Absolute paths keep fzf and Starship hooks matched to the selected packages.
  xdg.configFile."dev-config/shell.sh".text = ''
    # Recover a missing installer shell hook without changing project-shell PATH.
    if [ -z "''${IN_NIX_SHELL:-}" ] && ! command -v nix >/dev/null 2>&1 &&
       [ -r /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
      . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    fi
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
    for file in ${lib.escapeShellArg "${checkout}/nvim/init.lua"} \
      ${lib.escapeShellArg "${checkout}/starship.toml"} \
      ${lib.escapeShellArg "${checkout}/tmux/tmux.conf"} \
      ${lib.escapeShellArg "${checkout}/yazi/yazi.toml"} \
      ${lib.escapeShellArg "${checkout}/ghostty/config.ghostty"} \
      ${lib.escapeShellArg ghosttyPlatformConfig}; do
      if [ ! -f "$file" ]; then
        echo "Missing $file; rerun scripts/setup-home.sh from the current checkout location." >&2
        exit 1
      fi
    done
  '';
}
