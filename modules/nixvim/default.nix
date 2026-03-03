{
  inputs,
  pkgs,
  ...
}:
{
  imports = [ inputs.nixvim.homeModules.nixvim ];

  programs.nixvim = {
    enable = true;
    imports = [
      ./commands.nix
      ./completion.nix
      ./filesystem.nix
      ./git.nix
      ./keymaps.nix
      ./lsp
      ./options.nix
      ./snippets.nix
      ./telescope.nix
      ./treesitter.nix
      ./ui.nix
      ./utility.nix
    ];

    extraPackages = with pkgs; [
      lsof
    ];
  };
}
