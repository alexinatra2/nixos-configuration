{ self, ... }:
{
  local.base = {
    fullName = "Alexander Holzknecht";
    emailAddress = "alexander@woodservant.com";
  };

  imports = with self.modules.homeManager; [
    base
    fonts
    firefox
    mcp
    opencode
    shell
    thunderbird
    sops
  ];
}
