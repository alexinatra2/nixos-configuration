{
  programs.nvf.settings.vim = {
    telescope = {
      enable = true;
      mappings = {
        findFiles = "<leader>ff";
        liveGrep = "<leader>fg";
        diagnostics = "<leader>fd";
        gitCommits = "<leader>fc";
      };
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>fo";
        action = "<CMD>Telescope oldfiles<CR>";
        desc = "Old files [Telescope]";
        silent = true;
      }
      {
        mode = "n";
        key = "<leader>fh";
        action = "<CMD>Telescope command_history<CR>";
        desc = "Command history [Telescope]";
        silent = true;
      }
      {
        mode = "n";
        key = "<leader>ft";
        action = "<CMD>Telescope colorscheme<CR>";
        desc = "Colorscheme [Telescope]";
        silent = true;
      }
    ];
  };
}
