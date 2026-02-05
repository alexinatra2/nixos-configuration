{
  username,
  ...
}:
{
  programs.nh = {
    enable = true;
    flake = "/home/${username}/nixos-configuration";
    clean.enable = true;
  };
}
