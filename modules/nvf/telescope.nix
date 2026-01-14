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
        mode = [
          "n"
          "i"
          "x"
        ];
        key = "<leader>fo";
        action = "<ESC>Telescope oldfiles<CR>";
        silent = true;
      }
    ];
  };
}
