{ self, ... }:
let
  profileName = "alexander";
in
{
  flake.modules.homeManager.${profileName} = {
    imports = with self.modules.homeManager; [
      base
      firefox
      fonts
      generations
      git
      comfyui
      mcp
      neovim
      obsidian
      opencode
      pdf
      privatepackages
      shell
      slide-creation
      ssh
      stylix
      tmux
      music-creation
      llms
      sops
    ];
  };
}
