{ self, inputs, ... }:
{
  flake.nixosModules.users = {
    users.users."alexander" = {
      isNormalUser = true;
      hashedPassword = "$y$j9T$Iztq1/D8jn6wQf4ZOjJUh0$3QftpZFTD51SWvAdg5XKXVgbBkgw1ox9hoWWKgOvZO2";
      extraGroups = [
        "wheel"
        "adbusers"
        "docker"
        "networkmanager"
        "realtime"
        "audio"
      ];
    };
  };
}
