{ self, inputs, ... }:
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
      mcp
      neovim
      opencode
      rust
      shell
      ssh
      thunderbird
      tmux
      music-creation
      llms
      sops
    ];
  };
}
