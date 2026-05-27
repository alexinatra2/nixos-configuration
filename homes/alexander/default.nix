{ self, ... }:
{
  imports = with self.modules.homeManager; [
    fonts
    firefox
    mcp
    opencode
    shell
    thunderbird
    sops
  ];
}
