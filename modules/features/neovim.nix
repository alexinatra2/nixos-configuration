{ self, inputs, ... }:
{
  flake.modules.homeManager.neovim = {
    programs.neovim = {
      enable = true;
      viAlias = true;
      defaultEditor = true;
      withRuby = false;
      withPython3 = false;
    };

  };
}
