{
  inputs,
  ...
}:
{
  imports = [ inputs.nixvim.homeModules.nixvim ];

  programs.nixvim = {
    enable = true;
    imports = [
      ./options.nix
      ./keymaps.nix
      ./telescope.nix
      ./treesitter.nix
      ./git.nix
      ./oil.nix
      ./utility.nix
      ./lsp
    ];
  };
}
