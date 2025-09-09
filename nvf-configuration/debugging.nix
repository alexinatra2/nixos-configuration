{ ... }:
{
  programs.nvf.settings.vim = {
    debugger = {
      nvim-dap = {
        enable = true;
        ui.enable = true;
        mappings = {
          continue = "<F5>";
          stepOver = "<F10>";
          stepInto = "<F11>";
          stepOut = "<F12>";
          toggleBreakpoint = "<F9>";
          runToCursor = "<leader>dc";
        };
      };
    };
  };
}