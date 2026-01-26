{
  inputs,
  ...
}:
{
  imports = [ inputs.nixvim.homeModules.nixvim ];

  programs.nixvim = {
    enable = true;
    imports = [
      ./cmp.nix
      ./git.nix
      ./keymaps.nix
      ./lsp
      ./oil.nix
      ./options.nix
      ./telescope.nix
      ./treesitter.nix
      ./utility.nix
    ];
  };
}
