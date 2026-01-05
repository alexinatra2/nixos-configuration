{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    ollama
    eduvpn-client
    jetbrains.rust-rover
    discord
  ];
}
