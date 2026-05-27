{ self, inputs, ... }:
let
  profileName = "alexander";
in
{
  flake.modules.homeManager.${profileName} = {
    imports = with self.modules.homeManager; [
      firefox
      mcp
      opencode
      shell
      thunderbird
      sops
    ];
  };
}
