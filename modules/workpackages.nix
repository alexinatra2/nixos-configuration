{
  pkgs,
  lib,
  ...
}:
{
  # Only include Linux-specific graphics packages on non-Darwin systems
  home.packages = with pkgs; [
    jetbrains.idea
    gradle
    maven
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
  home.sessionVariables = {
    LD_LIBRARY_PATH = "${pkgs.mesa}/lib:${pkgs.libGL}/lib";
  };

  fonts.fontconfig.enable = pkgs.stdenv.isLinux;
  home.file."/.local/share/fonts/NerdFonts/JetBrainsMono".source =
    "${pkgs.nerd-fonts.jetbrains-mono}/share/fonts/truetype/NerdFonts/JetBrainsMono";

  programs.bash.profileExtra = ''
    if [ -f "$HOME/.config/env.local" ]; then
      . "$HOME/.config/env.local"
    fi
  '';
}
