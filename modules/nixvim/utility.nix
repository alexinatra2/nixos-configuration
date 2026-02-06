{
  # toggle a floating terminal using Alt-i
  plugins.toggleterm = {
    enable = true;

    settings = {
      direction = "float";
      open_mapping = "[[<A-i>]]";
      # attach to a static tmux session
      shell = "tmux new-session -A -s nvim-term";
    };
  };

  # navigate quickly using s
  plugins.flash.enable = true;
  keymaps = [
    {
      mode = [
        "n"
        "x"
        "o"
      ];
      key = "s";
      action = "<CMD>lua require('flash').jump()<CR>";
      options = {
        desc = "Flash jump";
        silent = true;
      };
    }
  ];

  # display available key bindings
  plugins.which-key.enable = true;

  # highlight yanked text
  plugins.yanky = {
    enable = true;
    enableTelescope = true;
    settings = {
      highlight = {
        on_put = true;
        on_yank = true;
        timer = 300;
      };
      preserve_cursor_position.enabled = true;
    };
  };

  # save nvim session state
  plugins.auto-session.enable = true;
}
