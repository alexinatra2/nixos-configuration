{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    jetbrains.idea
    mesa
    libGL
    libGLU
    xorg.libX11
    xorg.libXcursor
    xorg.libXi
    xorg.libXrandr
    xorg.libXxf86vm
    gradle
    maven
  ];

  # Ensure LD_LIBRARY_PATH includes system GL drivers
  home.sessionVariables = {
    LD_LIBRARY_PATH = "${pkgs.mesa}/lib:${pkgs.libGL}/lib";
  };

  fonts.fontconfig.enable = true;
  home.file."/.local/share/fonts/NerdFonts/JetBrainsMono".source =
    "${pkgs.nerd-fonts.jetbrains-mono}/share/fonts/truetype/NerdFonts/JetBrainsMono";
}
