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
      mcp
      neovim
      opencode
      rust
      shell
      ssh
      thunderbird
      music-creation
      llms
      sops
    ];
  };
}
