{
  config,
  username,
  ...
}:
{
  programs.nh = {
    enable = true;
    flake = "/${config.home.homeDirectory}/nixos-configuration";
    clean.enable = true;
  };
}
