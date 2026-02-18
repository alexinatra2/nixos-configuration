{
  flake.modules.homeManager.darwin-home =
    { pkgs, lib, ... }:
    let
      defaultDarwinUsername = "alexanderholzknecht";
    in
    {
      home.username = lib.mkDefault defaultDarwinUsername;
      home.homeDirectory = lib.mkForce "/Users/${defaultDarwinUsername}";

      firefox.enable = true;

      home.packages = with pkgs; [
        gradle
        maven
      ];
    };
}
