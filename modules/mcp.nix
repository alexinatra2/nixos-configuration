{ pkgs, ... }:
{
  home.packages = with pkgs; [
    uv
    nodejs
  ];

  programs.mcp = {
    enable = true;

    servers = {
      everything = {
        command = "npx";
        args = [
          "-y"
          "@modelcontextprotocol/server-everything"
        ];
      };

      context7 = {
        url = "https://mcp.context7.com/mcp";
        headers = {
          CONTEXT7_API_KEY = "{env:CONTEXT7_API_KEY}";
        };
      };

      nixos = {
        command = "nix";
        args = [
          "run"
          "github:utensils/mcp-nixos"
          "--"
        ];
      };

      typst-mcp = {
        type = "stdio";
        command = "uv";
        args = [
          "run"
          "--with"
          "git+https://github.com/FujishigeTemma/typst-mcp"
          "typst-mcp"
          "serve"
        ];
        env = { };
      };

      pdf-reader-mpc = {
        command = "npx";
        args = [ "@sylphx/pdf-reader-mcp" ];
      };

      playwright = {
        type = "local";
        command = "npx";
        args = [
          "@playwright/mcp@latest"
        ];
      };

      duckduckgo-search = {
        command = "npx";
        args = [
          "-y"
          "duckduckgo-mcp-server"
        ];
      };
    };
  };
}
