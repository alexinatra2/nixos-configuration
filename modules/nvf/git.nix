{
  config.vim = {
    git = {
      enable = true;
    };
    keymaps = [
      {
        mode = [
          "n"
          "x"
          "i"
        ];
        key = "<A-b>";
        action = "<CMD>Gitsigns blame<CR>";
        desc = "toggle blame [Gitsigns]";
        silent = true;
      }
    ];
    terminal.toggleterm.lazygit.enable = true;
  };
}
