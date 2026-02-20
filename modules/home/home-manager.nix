{
  flake.modules.homeManager.home-manager =
    { username, ... }:
    {
      programs.home-manager.enable = true;

      home.username = username;
      home.homeDirectory = "/home/${username}";
      home.stateVersion = "24.11";
    };
}
