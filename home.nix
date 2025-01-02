{
  config,
  pkgs,
  lib,
  username,
  nixvim,
  ...
}:
{
  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
    packages = with pkgs; [
      discord
      gcc
      lazydocker
      lazygit
      obsidian
      ripgrep
      slack
      teams-for-linux
      nixfmt-rfc-style
    ];
  };

  imports = [
    nixvim.homeManagerModules.nixvim
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };

  programs.nixvim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;

    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    performance = {
      combinePlugins.enable = true;
      byteCompileLua.enable = true;
    };

    clipboard = {
      # Use system clipboard
      register = "unnamedplus";

      providers.wl-copy.enable = true;
    };

    opts = {
      updatetime = 100; # Faster completion

      # Line numbers
      relativenumber = true; # Relative line numbers
      number = true; # Display the absolute line number of the current line
      hidden = true; # Keep closed buffer open in the background
      mouse = "a"; # Enable mouse control
      mousemodel = "extend"; # Mouse right-click extends the current selection
      splitbelow = true; # A new window is put below the current one
      splitright = true; # A new window is put right of the current one

      swapfile = false; # Disable the swap file
      modeline = true; # Tags such as 'vim:ft=sh'
      modelines = 100; # Sets the type of modelines
      # undofile = true; # Automatically save and restore undo history
      incsearch = true; # Incremental search: show match for partly typed search command
      inccommand = "split"; # Search and replace: preview changes in quickfix list
      ignorecase = true; # When the search query is lower-case, match both lower and upper-case
      #   patterns
      smartcase = true; # Override the 'ignorecase' option if the search pattern contains upper
      #   case characters
      scrolloff = 8; # Number of screen lines to show around the cursor
      cursorline = false; # Highlight the screen line of the cursor
      cursorcolumn = false; # Highlight the screen column of the cursor
      signcolumn = "yes"; # Whether to show the signcolumn
      colorcolumn = "80"; # Columns to highlight
      laststatus = 3; # When to use a status line for the last window
      fileencoding = "utf-8"; # File-content encoding for the current buffer
      termguicolors = true; # Enables 24-bit RGB color in the |TUI|
      spell = false; # Highlight spelling mistakes (local to window)
      wrap = false; # Prevent text from wrapping

      # Tab options
      tabstop = 2; # Number of spaces a <Tab> in the text stands for (local to buffer)
      shiftwidth = 2; # Number of spaces used for each step of (auto)indent (local to buffer)
      expandtab = true; # Expand <Tab> to spaces in Insert mode (local to buffer)
      autoindent = true; # Do clever autoindenting

      textwidth = 0; # Maximum width of text that is being inserted.  A longer line will be
      #   broken after white space to get this width.

      # Folding
      foldlevel = 99; # Folds with a level higher than this number will be closed
    };

    colorschemes.gruvbox.enable = true;

    plugins = {
      lz-n.enable = true;

      lualine.enable = true;
      which-key.enable = true;

      lsp-format = {
        enable = true;
        lspServersToEnable = "all";
      };

      oil = {
        enable = true;
        lazyLoad.settings.cmd = "Oil";
      };

      web-devicons.enable = true;

      startify.enable = true;

      neo-tree = {
        enable = true;

        closeIfLastWindow = true;
        window = {
          width = 30;
          autoExpandWidth = true;
        };
      };

      lsp = {
        enable = true;
        servers = {
          nixd.enable = true;
          ts_ls.enable = true;
          rust_analyzer = {
            enable = true;
            installRustc = true;
            installCargo = true;
          };
        };
      };

      treesitter = {
        enable = true;

        nixvimInjections = true;

        settings = {
          highlight.enable = true;
          indent.enable = true;
        };
        folding = true;
      };

      treesitter-refactor = {
        enable = true;
        highlightDefinitions = {
          enable = true;
          # Set to false if you have an `updatetime` of ~100.
          clearOnCursorMove = false;
        };
      };

      telescope = {
        enable = true;

        keymaps = {
          # Find files using Telescope command-line sugar.
          "<leader>ff" = "find_files";
          "<leader>fg" = "live_grep";
          "<leader>b" = "buffers";
          "<leader>fh" = "help_tags";
          "<leader>fd" = "diagnostics";

          # FZF like bindings
          "<C-p>" = "git_files";
          "<leader>p" = "oldfiles";
          "<C-f>" = "live_grep";
        };

        settings.defaults = {
          file_ignore_patterns = [
            "^.git/"
            "^.mypy_cache/"
            "^__pycache__/"
            "^output/"
            "^data/"
            "%.ipynb"
          ];
          set_env.COLORTERM = "truecolor";
        };
      };

      harpoon = {
        enable = true;

        keymapsSilent = true;

        keymaps = {
          addFile = "<leader>a";
          toggleQuickMenu = "<C-e>";
          navFile = {
            "1" = "<C-h>";
            "2" = "<C-j>";
            "3" = "<C-k>";
            "4" = "<C-l>";
          };
        };
      };

      floaterm = {
        enable = true;

        settings.keymap_toggle = "<leader>,";
      };

      luasnip.enable = true;

      lspkind = {
        enable = true;

        cmp = {
          enable = true;
          menu = {
            nvim_lsp = "[LSP]";
            nvim_lua = "[api]";
            path = "[path]";
            luasnip = "[snip]";
            buffer = "[buffer]";
            neorg = "[neorg]";
            nixpkgs_maintainers = "[nixpkgs]";
          };
        };
      };

      cmp = {
        enable = true;

        settings = {
          snippet.expand = "function(args) require('luasnip').lsp_expand(args.body) end";

          mapping = {
            "<C-d>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-e>" = "cmp.mapping.close()";
            "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
            "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
          };

          sources = [
            { name = "path"; }
            { name = "nvim_lsp"; }
            { name = "luasnip"; }
            {
              name = "buffer";
              # Words from other open buffers can also be suggested.
              option.get_bufnrs.__raw = "vim.api.nvim_list_bufs";
            }
            { name = "neorg"; }
            { name = "nixpkgs_maintainers"; }
          ];
        };
      };

      gitsigns = {
        enable = true;
        settings.signs = {
          add.text = "+";
          change.text = "~";
        };
      };

      lazygit = {
        enable = true;
      };

      nvim-autopairs.enable = true;

      colorizer = {
        enable = true;
        settings.user_default_options.names = false;
      };

      tmux-navigator.enable = true;
      diffview.enable = true;
    };

    keymaps =
      let
        normal =
          lib.mapAttrsToList
            (key: action: {
              mode = "n";
              inherit action key;
            })
            {
              "<Space>" = "<NOP>";

              # Esc to clear search results
              "<esc>" = ":noh<CR>";

              # fix Y behaviour
              Y = "y$";

              # back and fourth between the two most recent files
              "<C-c>" = ":b#<CR>";

              # close by Ctrl+x
              "<C-x>" = ":close<CR>";

              # save by Space+s or Ctrl+s
              "<C-s>" = ":w<CR>";

              # Press 'H', 'L' to jump to start/end of a line (first/last character)
              L = "$";
              H = "^";

              # move current line up/down
              # M = Alt key
              "<M-k>" = ":move-2<CR>";
              "<M-j>" = ":move+<CR>";

              # plugins
              "<leader>e" = ":Neotree action=focus reveal toggle<CR>";
              "<leader>g" = ":LazyGit<CR>";
            };
        visual =
          lib.mapAttrsToList
            (key: action: {
              mode = "v";
              inherit action key;
            })
            {
              # better indenting
              ">" = ">gv";
              "<" = "<gv";
              "<TAB>" = ">gv";
              "<S-TAB>" = "<gv";

              # move selected line / block of text in visual mode
              "K" = ":m '<-2<CR>gv=gv";
              "J" = ":m '>+1<CR>gv=gv";

              # sort
              "<leader>s" = ":sort<CR>";
            };
        insert =
          lib.mapAttrsToList
            (key: action: {
              mode = "i";
              inherit action key;
            })
            {
              "<C-s>" = "<esc>:w<CR>";

              "jj" = "<esc>";
            };
      in
      config.lib.nixvim.keymaps.mkKeymaps { options.silent = true; } (normal ++ visual ++ insert);
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
