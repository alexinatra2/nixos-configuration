{
  config,
  pkgs,
  lib,
  username,
  ...
}:
{
  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
    packages = with pkgs; [
      android-studio
      discord
      gcc
      jetbrains-toolbox
      lazydocker
      lazygit
      libreoffice-qt6-fresh
      nixfmt-rfc-style
      nodejs
      obsidian
      pnpm
      ripgrep
      slack
      synology-drive-client
      teams-for-linux
    ];
  };

  imports = [
    ./nvf-configuration
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "alexinatra2";
    userEmail = "a.holzknecht@gmx.de";
  };

  # starship - an customizable prompt for any shell
  programs.starship = {
    enable = true;
  };

  programs.fzf = {
    enable = true;
  };

  programs.tmux = {
    enable = true;
    prefix = "C-Space";
    extraConfig = ''
      set -g base-index 1
      setw -g pane-base-index 1

      set -g renumber-windows on

      # Use emacs keybindings in the status line
      set-option -g status-keys emacs

      # Use vim keybindings in copy mode
      setw -g mode-keys vi

      # Fix ESC delay in vim
      set -g escape-time 10

      unbind-key -T copy-mode-vi v

      bind-key -T copy-mode-vi v \
        send-keys -X begin-selection

      bind-key -T copy-mode-vi 'C-v' \
        send-keys -X rectangle-toggle

      bind-key -T copy-mode-vi y \
        send-keys -X copy-pipe-and-cancel "pbcopy"

      bind-key -T copy-mode-vi MouseDragEnd1Pane \
        send-keys -X copy-pipe-and-cancel "pbcopy"

      bind c new-window -c '#{pane_current_path}'
      bind '\' split-window -h -c '#{pane_current_path}'
      bind - split-window -v -c '#{pane_current_path}'

      set-option -g status-justify left
      set-option -g status-left-length 16
      set-option -g status-left '#[bg=colour72] #[bg=colour237] #[bg=colour236] #[bg=colour235]#[fg=colour185] #S #[bg=colour236] '
      set-option -g status-bg colour237
      set-option -g status-right '#[bg=colour236] #[bg=colour235]#[fg=colour185] %a %R #[bg=colour236]#[fg=colour3] #[bg=colour237] #[bg=colour72] #[]'
      set-option -g status-interval 60

      set-option -g pane-active-border-style fg=colour246
      set-option -g pane-border-style fg=colour238

      set-window-option -g window-status-format '#[bg=colour238]#[fg=colour107] #I #[bg=colour239]#[fg=colour110] #[bg=colour240]#W#[bg=colour239]#[fg=colour195]#F#[bg=colour238] '
      set-window-option -g window-status-current-format '#[bg=colour236]#[fg=colour215] #I #[bg=colour235]#[fg=colour167] #[bg=colour234]#W#[bg=colour235]#[fg=colour195]#F#[bg=colour236] '
    '';
  };

  programs.alacritty = {
    enable = true;
  };

  programs.lazygit = {
    enable = true;
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      lg = "lazygit";
      ld = "lazydocker";
      open = "xdg-open";
      cd = "z";
    };
    initExtra = ''
      # tat: tmux attach
      function tat {
        name=$(basename `pwd` | sed -e 's/\.//g')

        if tmux ls 2>&1 | grep "$name"; then
          tmux attach -t "$name"
        elif [ -f .envrc ]; then
          direnv exec / tmux new-session -s "$name"
        else
          tmux new-session -s "$name"
        fi
      }
    '';
  };

  programs.zoxide = {
    enable = true;
  };

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface".color-scheme = "prefer-dark";
      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = with pkgs.gnomeExtensions; [
          caffeine.extensionUuid
        ];
      };
    };
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true; # see note on other shells below
    nix-direnv.enable = true;
  };

  programs.kitty = {
    enable = true;
    settings = {
      cursor_trail = 2;
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";
      bind =
        [
          "$mod, F, exec, firefox"
          ", Print, exec, grimblast copy area"
        ]
        ++ (
          # workspaces
          # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
          builtins.concatLists (
            builtins.genList (
              i:
              let
                ws = i + 1;
              in
              [
                "$mod, code:1${toString i}, workspace, ${toString ws}"
                "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
              ]
            ) 9
          )
        );
      env = [
        "LIBVA_DRIVER_NAME,nvidia"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
      ];
    };
  };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
