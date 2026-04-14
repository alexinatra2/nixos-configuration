{
  pkgs,
  ...
}:
{
  imports = [
    # ./xremap.nix
  ];

  home.packages = with pkgs; [
    eduvpn-client
    qgis
  ];
}
