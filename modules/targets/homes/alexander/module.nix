{ self, inputs, ... }:
let
  profileName = "alexander";
in
{
  flake.modules.homeManager.${profileName} = {
    imports = with self.modules.homeManager; [
      fonts
      firefox
      mcp
      opencode
      shell
      thunderbird
      sops
    ];
  };
}
