{ ... }:
{
  plugins.opencode = {
    enable = true;
    settings = {
      events.reload = true;
      lsp.enabled = false;
      prompts = {
        review.prompt = "Review @this for correctness, readability, and edge cases";
        test.prompt = "Add or improve tests for @this";
      };
    };
  };

  keymaps = [
    {
      mode = [
        "n"
        "x"
      ];
      key = "<leader>oa";
      action.__raw = ''
        function()
          require("opencode").ask("@this: ", { submit = true })
        end
      '';
      options = {
        silent = true;
        desc = "Ask opencode about selection";
      };
    }
    {
      key = "<leader>oo";
      action.__raw = ''
        function()
          require("opencode").select()
        end
      '';
      options = {
        silent = true;
        desc = "Open opencode actions";
      };
    }
    {
      mode = [
        "n"
        "t"
      ];
      key = "<leader>ot";
      action.__raw = ''
        function()
          require("opencode").toggle()
        end
      '';
      options = {
        silent = true;
        desc = "Toggle opencode";
      };
    }
    {
      key = "<leader>on";
      action.__raw = ''
        function()
          require("opencode").command("session.new")
        end
      '';
      options = {
        silent = true;
        desc = "New opencode session";
      };
    }
  ];
}
