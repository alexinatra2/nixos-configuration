{ self, inputs, ... }:
let
  profileName = "alexander";
in
{
  flake.modules.homeManager.${profileName} = {
    imports = with self.modules.homeManager; [
      firefox
      fonts
      mcp
      opencode
      shell
      thunderbird
      sops
    ];
  };
}
