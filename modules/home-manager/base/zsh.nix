{
  pkgs,
  config,
  ...
}: let
  # init scripts rendered at build time; eval-ing `tool init zsh` on every
  # shell start would fork the tool just to print a static script
  mkZshInit = name: cmd: pkgs.runCommand "${name}-init.zsh" {} "${cmd} > $out";
  zoxideInit = mkZshInit "zoxide" "${pkgs.zoxide}/bin/zoxide init zsh";
  starshipInit = mkZshInit "starship" "${pkgs.starship}/bin/starship init zsh --print-full-init";
  fzfInit = mkZshInit "fzf" "${pkgs.fzf}/bin/fzf --zsh";
in {
  home.shellAliases = {
    c = "code .";
    lg = "lazygit";
    s = "ssh";
    devv = "nix develop -c zellij -s `basename $PWD` options --default-shell zsh";
    k = "kubectl";
    ur = "uv run";
  };

  programs.zsh = {
    enable = true;
    dotDir = config.home.homeDirectory; # lock legacy default, silences warning
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "gh"
        "composer"
        "rsync"
        "aws"
      ];
      # Startup speed: skip the compaudit security scan (completion dirs are
      # all read-only nix store paths, it can never find anything), and key
      # the completion dump on the store hash of the current profile
      # generation. Only the first shell of a new generation pays the full
      # fpath scan; every other shell loads the cached dump with compinit -C
      # and turns oh-my-zsh's own compinit call into a no-op (the real
      # compinit is restored in initContent, after oh-my-zsh has loaded).
      extraConfig = ''
        ZSH_DISABLE_COMPFIX="true"

        zmodload -F zsh/files b:zf_mkdir b:zf_rm
        _zdump_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
        zf_mkdir -p "$_zdump_dir"
        _profile="/etc/profiles/per-user/$USER"
        [[ -e "$_profile" ]] || _profile="$HOME/.nix-profile"
        ZSH_COMPDUMP="$_zdump_dir/zcompdump-''${_profile:A:t}-$ZSH_VERSION"
        # only trust the dump if it starts with real compinit content;
        # oh-my-zsh appends its own metadata to the file, so non-empty
        # alone doesn't mean valid
        if [[ -s "$ZSH_COMPDUMP" ]] && read -r _l < "$ZSH_COMPDUMP" && [[ "$_l" == "#files:"* ]]; then
          autoload -Uz compinit
          compinit -C -d "$ZSH_COMPDUMP"
          # oh-my-zsh's compinit call becomes a no-op — unless oh-my-zsh
          # decided the dump is stale and deleted it first, then fall
          # through to the real compinit so the dump gets rebuilt
          compinit() {
            if [[ ! -s "$ZSH_COMPDUMP" ]]; then
              unfunction compinit
              autoload -Uz compinit
              compinit "$@"
            fi
          }
          _compinit_stubbed=1
        fi
        # drop dumps left over from old generations
        for _f in "$_zdump_dir"/zcompdump-*(N.m+30); do
          [[ "$_f" == "$ZSH_COMPDUMP"* ]] || zf_rm -f -- "$_f"
        done
        unset _zdump_dir _profile _f _l
      '';
    };

    initContent = ''
      # restore the real compinit stubbed out in oh-my-zsh.extraConfig
      if [[ -n "$_compinit_stubbed" ]]; then
        unfunction compinit
        autoload -Uz compinit
        unset _compinit_stubbed
      fi

      source ${zoxideInit}
      if [[ $options[zle] = on ]]; then
        source ${fzfInit}
      fi
      if [[ $TERM != "dumb" ]]; then
        source ${starshipInit}
      fi

      ### Fix slowness of pastes with zsh-syntax-highlighting.zsh
      pasteinit() {
        OLD_SELF_INSERT=''${''${(s.:.)widgets[self-insert]}[2,3]}
        zle -N self-insert url-quote-magic # I wonder if you'd need `.url-quote-magic`?
      }

      pastefinish() {
        zle -N self-insert $OLD_SELF_INSERT
      }
      zstyle :bracketed-paste-magic paste-init pasteinit
      zstyle :bracketed-paste-magic paste-finish pastefinish
      ### Fix slowness of pastes

      # iterm2 integration
      if [ -f $HOME/.iterm2_shell_integration.zsh ]; then
        source $HOME/.iterm2_shell_integration.zsh
      fi

      run() {
        _pkg=$1
        shift
        NIXPKGS_ALLOW_UNFREE=1 nix run --impure "nixpkgs#$_pkg" -- $*
        unset _pkg
      }

      shell() {
        _pkgs=()
        for _pkg in "$@"; do
          _pkgs+=("nixpkgs#$_pkg")
        done
        nix shell "''${_pkgs[@]}"
      }

      # vi mode
      # bindkey -v
    '';
  };

  # zsh hooks come from the build-time init scripts in initContent above
  programs.starship = {
    enable = true;
    enableZshIntegration = false;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = false;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = false;
  };

  programs.broot = {
    enable = true;
    enableZshIntegration = true; # already a static file, no fork
  };

  home.file.".config/starship.toml".source = ./config/starship.toml;
  home.file.".iterm2_shell_integration.zsh".source = ./config/iterm2_shell_integration.zsh;
}
