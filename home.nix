{
  config,
  pkgs,
  lib,
  username,
  nixvim,
  ...
}:
{
  home.username = "${username}";
  home.homeDirectory = "/home/${username}"; 
 
  imports = [
    nixvim.homeManagerModules.nixvim
  ];
  
  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    gcc
    ripgrep
    jetbrains-mono
    lazygit
    lazydocker
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraPlugins = with pkgs.vimPlugins; [
      nvim-lspconfig
    ];
    extraConfigLua = ''
      vim.wo.relativenumber = true
      require("lspconfig").nixd.setup({
      	cmd = { "nixd" },
      	settings = {
      		nixd = {
      			nixpkgs = {
      				expr = "import <nixpkgs> { }",
      			},
      			formatting = {
      				command = { "nixfmt" }
      			},
      		},
      	},
      })
    '';
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

#  programs.neovim = {
#    enable = true;
#    plugins = with pkgs.vimPlugins; [
#      nvim-lspconfig
#      lualine-nvim
#    ];
#  };

  programs.tmux = {
    enable = true;
    prefix = "C-Space";
    extraConfig = ''
      set-option -g status-justify left
      set-option -g status-left '#[bg=colour72] #[bg=colour237] #[bg=colour236] #[bg=colour235]#[fg=colour185] #S #[bg=colour236] '
      set-option -g status-left-length 16
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
