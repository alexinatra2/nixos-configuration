{
  pkgs,
  lib,
  ...
}:
{
  # Only include Linux-specific graphics packages on non-Darwin systems
  home.packages =
    with pkgs;
    [
      jetbrains.idea
      gradle
      maven
    ]
    ++ lib.optionals (!pkgs.stdenv.isDarwin) [
      mesa
      libGL
      libGLU
      xorg.libX11
      xorg.libXcursor
      xorg.libXi
      xorg.libXrandr
      xorg.libXxf86vm
    ];

  # Ensure LD_LIBRARY_PATH includes system GL drivers (Linux only)
  home.sessionVariables = lib.mkIf (!pkgs.stdenv.isDarwin) {
    LD_LIBRARY_PATH = "${pkgs.mesa}/lib:${pkgs.libGL}/lib";
  };

  fonts.fontconfig.enable = true;
  home.file."/.local/share/fonts/NerdFonts/JetBrainsMono".source =
    "${pkgs.nerd-fonts.jetbrains-mono}/share/fonts/truetype/NerdFonts/JetBrainsMono";
}
