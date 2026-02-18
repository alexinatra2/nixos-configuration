# Neovim LSP (Language Server Protocol) aspect
{ inputs, ... }:
{
  config.flake.modules.homeManager.vim-lsp =
    { pkgs, ... }:
    {
      programs.nixvim = {
        plugins.lsp = {
          enable = true;
          inlayHints = true;
          onAttach = ''
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          '';
        };

        plugins.lsp-format.enable = true;

        # LSP keymaps
        keymaps = [
          {
            key = "gd";
            action = "<cmd>Lspsaga goto_definition<CR>";
            options = {
              desc = "Goto Definition";
              silent = true;
            };
          }
          {
            key = "gD";
            action = "<cmd>Lspsaga finder ref<CR>";
            options = {
              desc = "Goto References";
              silent = true;
            };
          }
          {
            key = "K";
            action = "<cmd>Lspsaga hover_doc<CR>";
            options = {
              desc = "Hover";
              silent = true;
            };
          }
          {
            key = "<leader>r";
            action = "<cmd>Lspsaga rename<CR>";
            options = {
              desc = "Rename";
              silent = true;
            };
          }
          {
            key = "<M-n>";
            action = "<cmd>Lspsaga diagnostic_jump_next<CR>";
            options = {
              desc = "Next Diagnostic";
              silent = true;
            };
          }
          {
            key = "<M-N>";
            action = "<cmd>Lspsaga diagnostic_jump_prev<CR>";
            options = {
              desc = "Previous Diagnostic";
              silent = true;
            };
          }
          {
            key = "<M-CR>";
            action = "<cmd>Lspsaga code_action<CR>";
            options = {
              desc = "Code Action";
              silent = true;
            };
          }
          {
            key = "<M-o>";
            action = "<cmd>Lspsaga outline<CR>";
            options = {
              desc = "Outline";
              silent = true;
            };
          }
        ];
      };
    };
}
