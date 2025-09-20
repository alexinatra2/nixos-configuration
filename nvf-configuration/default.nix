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

      git.enable = true;

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
        ruff
        shellcheck
        lua-language-server
        pyright
        gopls
        rust-analyzer
      ];
    };
  };
}
