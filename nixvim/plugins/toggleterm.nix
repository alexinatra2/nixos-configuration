{ ... }:
{
  plugins.toggleterm = {
    enable = true;
    settings = {
      direction = "float";
      open_mapping = "[[<M-i>]]";
      shell = "tmux new-session -A -s nvim-term";
    };
  };
}
