{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./keymaps.nix
    ./lsp.nix
    ./telescope.nix
    ./toggleterm.nix
    # ./treesitter.nix
    ./ui.nix
    ./utility.nix
    ./debugging.nix
    ./extra-plugins
  ];

  programs.nvf = {
    enable = true;
    settings.vim = {
      viAlias = true;
      vimAlias = true;

      preventJunkFiles = true;
      undoFile.enable = true;
      searchCase = "smart";

      options = {
        autoindent = true;
        mouse = "a";
        shiftwidth = 2;
        tabstop = 2;
      };

      statusline.lualine.enable = true;
      binds.whichKey.enable = true;
      autocomplete = {
        nvim-cmp = {
          enable = true;
          sources = {
            nvim_lsp = "[LSP]";
            luasnip = "[Snippet]";
            buffer = "[Buffer]";
            nvim_lua = "[Lua]";
            path = "[Path]";
            copilot = "[Copilot]";
          };
          setupOpts = {
            experimental.ghost_text = true;
            window = {
              completion.border = "rounded";
              documentation.border = "rounded";
            };
          };
        };
      };
      
      snippets = {
        luasnip.enable = true;
      };

      git.enable = true;
      comments.comment-nvim.enable = true;
      dashboard.dashboard-nvim.enable = true;

      spellcheck = {
        enable = true;
        languages = [ "en" ];
      };

      extraPackages = with pkgs; [
        cargo
        rustc
        rustfmt
        ripgrep
        # Formatters
        nixfmt-rfc-style
        prettier
        stylua
        black
        isort
        # Linters
        eslint_d
        ruff
        shellcheck
        # Language servers and tools
        nodePackages.typescript-language-server
        nodePackages.vscode-langservers-extracted
        lua-language-server
        pyright
        gopls
        rust-analyzer
      ];

      assistant.copilot = {
        enable = true;
        cmp.enable = true;
      };
    };
  };
}
