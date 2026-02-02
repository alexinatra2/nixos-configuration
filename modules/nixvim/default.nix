{
  inputs,
  ...
}:
{
  imports = [ inputs.nixvim.homeModules.nixvim ];

  programs.nixvim = {
    enable = true;
    imports = [
      ./completion.nix
      ./git.nix
      ./keymaps.nix
      ./lsp
      ./filesystem.nix
      ./options.nix
      ./telescope.nix
      ./treesitter.nix
      ./utility.nix
    ];
  };
}
