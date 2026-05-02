{ ... }:
{
  imports = [
    ./core.nix
    ./keymaps.nix
    ./plugins.nix
    ./lsp.nix
  ];

  config = {
    viAlias = true;
    vimAlias = true;
  };
}
