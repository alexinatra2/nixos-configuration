{
  # toggle a floating terminal using Meta-i
  plugins.toggleterm = {
    enable = true;

    settings = {
      direction = "float";
      open_mapping = "[[<M-i>]]";
      # attach to a static tmux session
      shell = "tmux new-session -A -s nvim-term";
    };
  };

  # display available key bindings
  plugins.which-key.enable = true;
  # highlight yanked text
  plugins.yanky.enable = true;
  # save nvim session state
  plugins.auto-session.enable = true;
}
