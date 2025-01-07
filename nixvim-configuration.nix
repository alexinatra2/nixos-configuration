{
  pkgs,
  lib,
  config,
  ...
}:
{
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
      # patterns
      smartcase = true; # Override the 'ignorecase' option if the search pattern contains upper
      # case characters
      scrolloff = 8; # Number of screen lines to show around the cursor
      cursorline = false; # Highlight the screen line of the cursor
      cursorcolumn = false; # Highlight the screen column of the cursor
      signcolumn = "yes"; # Whether to show the signcolumn
      # colorcolumn = "80"; # Columns to highlight
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
      lsp = {
        enable = true;
        keymaps.lspBuf = {
          K = "hover";
          gD = "references";
          gd = "definition";
          gi = "implementation";
          gt = "type_definition";
        };
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

      lsp-format = {
        enable = true;
        lspServersToEnable = "all";
      };

      # highlighting
      treesitter = {
        enable = true;

        nixvimInjections = true;

        settings = {
          highlight.enable = true;
          indent.enable = true;
        };

        folding = true;
      };

      # fuzzy finding popup
      telescope = {
        enable = true;

        keymaps = {
          "<leader>f" = "find_files";
          "<leader>/" = "live_grep";
          "<leader>b" = "buffers";
          "<leader>d" = "diagnostics";
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
          toggleQuickMenu = "<leader>s";
          navFile = {
            "1" = "<leader>h";
            "2" = "<leader>j";
            "3" = "<leader>k";
            "4" = "<leader>l";
          };
        };
      };

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

      # integrated floating terminal
      floaterm = {
        enable = true;

        settings = {
          title = "";
          keymap_toggle = "<leader>,";
        };
      };

      # edit the file explorer as if it were a file
      oil = {
        enable = true;
        settings = {
          view_options = {
            show_hidden = true;
          };
        };
      };

      # show lines that help with indentation
      indent-blankline.enable = true;
      # show the color of hex strings as background of the color
      colorizer.enable = true;
      # enable lazy loading of plugins
      lz-n.enable = true;
      # the line indicating vim mode, branch, file, etc.
      lualine.enable = true;
      # the popup that shows available keybindings
      which-key.enable = true;
      # enable icons for nixvim
      web-devicons.enable = true;
      # generate a startmenu
      startify.enable = true;
      # automatically store sessions of nvim which get reactivated when accessing
      # a new session in the same directory
      auto-session.enable = true;
      # snippets
      luasnip.enable = true;
      # tmux navigation within nvim (e.g. C-h to go to the buffer on the left)
      tmux-navigator.enable = true;
      # improve the ui for code actions etc. to look like telescope
      dressing.enable = true;
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
              "<C-w>" = ":close<CR>";

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
              "-" = ":Oil<CR>";
              "<M-CR>" = ":lua vim.lsp.buf.code_action()<CR>";
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
              "<M-BS>" = "<C-w>";
              "<M-CR>" = ":lua vim.lsp.buf.code_action()<CR>";
            };
      in
      config.lib.nixvim.keymaps.mkKeymaps { options.silent = true; } (normal ++ visual ++ insert);
  };
}
