{
  inputs,
  ...
}:
{
  imports = [ inputs.nixvim.homeModules.nixvim ];

  programs.nixvim = {
    enable = true;
    imports = [
      ./ai.nix
      ./completion.nix
      ./filesystem.nix
      ./git.nix
      ./keymaps.nix
      ./lsp
      ./options.nix
      ./telescope.nix
      ./treesitter.nix
      ./ui.nix
      ./utility.nix
    ];
  };
}
