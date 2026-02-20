{
  flake.modules.homeManager.work =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        jetbrains.idea
        gradle
        maven
        mesa
        libGL
        libGLU
        libX11
        libXcursor
        libXi
        libXrandr
        libXxf86vm
      ];

      home.sessionVariables = {
        LD_LIBRARY_PATH = "${pkgs.mesa}/lib:${pkgs.libGL}/lib";
      };

      fonts.fontconfig.enable = pkgs.stdenv.isLinux;
      home.file."/.local/share/fonts/NerdFonts/JetBrainsMono".source =
        "${pkgs.nerd-fonts.jetbrains-mono}/share/fonts/truetype/NerdFonts/JetBrainsMono";
    };
}
