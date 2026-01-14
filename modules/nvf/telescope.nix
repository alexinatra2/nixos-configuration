{
  programs.nvf.settings.vim = {
    telescope = {
      enable = true;
      mappings = {
        findFiles = "<leader>ff";
        liveGrep = "<leader>fg";
        diagnostics = "<leader>fd";
        gitCommits = "<leader>fc";
        gitStatus = "<leader>fs";
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
    ];
  };
}
