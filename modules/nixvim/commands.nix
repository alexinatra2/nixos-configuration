{
  userCommands = {
    MergedLogs = {
      desc = "Open last 500 lines of Neovim logs in vertical terminal";
      command = ''
        :vertical terminal bash -c 'find $HOME/.local/state/nvim -type f -name "*.log" | xargs -I{} tail -n 500 "{}" | sort -r'
      '';
      nargs = 0;
      force = true;
    };
  };
}
