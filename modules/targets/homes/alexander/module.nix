{ self, ... }:
let
  profileName = "alexander";
in
{
  flake.modules.homeManager.${profileName} = {
    imports = [
      self.modules.homeManager.base
      self.modules.homeManager.firefox
      self.modules.homeManager.fonts
      self.modules.homeManager.generations
      self.modules.homeManager.git
      self.modules.homeManager.comfyui
      self.modules.homeManager.mcp
      self.modules.homeManager.neovim
      self.modules.homeManager.obsidian
      self.modules.homeManager.opencode
      self.modules.homeManager.pdf
      self.modules.homeManager.privatepackages
      self.modules.homeManager.shell
      self.modules.homeManager.slide-creation
      self.modules.homeManager.ssh
      self.modules.homeManager.stylix
      self.modules.homeManager.tmux
      self.modules.homeManager.music-creation
      self.modules.homeManager.llms
      self.modules.homeManager.sops
    ];
  };
}
