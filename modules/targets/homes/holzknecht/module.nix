{ self, ... }:
let
  profileName = "holzknecht";
in
{
  flake.modules.homeManager.${profileName} = {
    imports = [
      self.modules.homeManager.base
      self.modules.homeManager.firefox
      self.modules.homeManager.fonts
      self.modules.homeManager.generations
      self.modules.homeManager.git
      self.modules.homeManager.mcp
      self.modules.homeManager.neovim
      self.modules.homeManager.opencode
      self.modules.homeManager.pdf
      self.modules.homeManager.shell
      self.modules.homeManager.stylix
      self.modules.homeManager.tmux
    ];
  };
}
