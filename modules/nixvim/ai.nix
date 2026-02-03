{
  plugins.copilot = {
    enable = true;
    settings = {
      suggestion = {
        enabled = true;
      };
      panel = {
        enabled = false;
      };
    };
  };

  plugins.copilot-chat.enable = true;

  plugins.opencode = {
    enable = true;
    settings = {
      input.enabled = true;
      auto_reload = true;
    };
  };

  keymaps = [
    {
      key = "<A-a>";
      action = "<CMD>lua require('opencode').toggle()<CR>";
      options = {
        desc = "Toggle OpenCode side panel";
        silent = true;
      };
    }
  ];
}
