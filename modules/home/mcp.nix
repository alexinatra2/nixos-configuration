{ self, inputs, ... }:
{
  flake.modules.homeManager.mcp =
    {
      pkgs,
      lib,
      options,
      ...
    }:
    let
      hasMcp = options ? programs.mcp;
    in
    {
      config = lib.mkMerge [
        {
          home.packages = with pkgs; [
            uv
            nodejs
          ];
        }
        (lib.mkIf hasMcp {
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

              # typst-mcp = {
              #   type = "stdio";
              #   command = "uv";
              #   args = [
              #     "run"
              #     "--with"
              #     "git+https://github.com/FujishigeTemma/typst-mcp"
              #     "typst-mcp"
              #     "serve"
              #   ];
              #   env = { };
              # };

              pdf-reader-mpc = {
                command = "npx";
                args = [ "@sylphx/pdf-reader-mcp" ];
              };

              playwright = {
                type = "local";
                command = "npx";
                args = [ "@playwright/mcp@latest" ];
              };

              duckduckgo-search = {
                command = "npx";
                args = [
                  "-y"
                  "duckduckgo-mcp-server"
                ];
              };

              slidev-mcp = {
                command = "npx";
                args = [
                  "-y"
                  "slidev-mcp"
                ];
              };

              sequential-thinking = {
                command = "npx";
                args = [
                  "-y"
                  "@modelcontextprotocol/server-sequential-thinking"
                ];
              };

              google-maps-platform-code-assist = {
                command = "npx";
                args = [
                  "-y"
                  "@googlemaps/code-assist-mcp@latest"
                ];
              };

              computer-use = {
                command = "npx";
                args = [
                  "-y"
                  "computer-use-mcp"
                ];
              };
            };
          };
        })
      ];
    };
}
