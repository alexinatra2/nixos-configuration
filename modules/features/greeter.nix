{ self, ... }:
{
  flake.nixosModules.greeter =
    {
      config,
      pkgs,
      ...
    }:
    let
      inherit (config.lib.stylix.colors) base00 base03 base05 base08 base0A base0B;
      inherit (config.lib.stylix) mkHexColor;

      themeName = "ly-colormix";
      spinnerThemeDir = "${pkgs.plymouth}/share/plymouth/themes/spinner";

      lyLogoSvg = pkgs.writeText "${themeName}.svg" ''
        <svg xmlns="http://www.w3.org/2000/svg" width="640" height="200" viewBox="0 0 640 200">
          <rect x="80" y="40" width="360" height="28" rx="14" fill="#${base08}" />
          <rect x="140" y="86" width="360" height="28" rx="14" fill="#${base0B}" />
          <rect x="200" y="132" width="360" height="28" rx="14" fill="#${base0A}" />
        </svg>
      '';

      lyLogo = pkgs.runCommand "${themeName}-logo.png" { nativeBuildInputs = [ pkgs.librsvg ]; } ''
        rsvg-convert --background-color=transparent --format=png --output "$out" "${lyLogoSvg}"
      '';

      plymouthThemeFile = pkgs.writeText "${themeName}.plymouth" ''
        [Plymouth Theme]
        Name=Ly Colormix
        Description=Spinner theme coloured to match the ly greeter.
        ModuleName=two-step

        [two-step]
        Font=Cantarell 12
        TitleFont=Cantarell Light 30
        ImageDir=${spinnerThemeDir}
        DialogHorizontalAlignment=.5
        DialogVerticalAlignment=.382
        TitleHorizontalAlignment=.5
        TitleVerticalAlignment=.382
        HorizontalAlignment=.5
        VerticalAlignment=.7
        WatermarkHorizontalAlignment=.5
        WatermarkVerticalAlignment=.46
        Transition=none
        TransitionDuration=0.0
        BackgroundStartColor=${mkHexColor base00}
        BackgroundEndColor=${mkHexColor base00}
        ProgressBarBackgroundColor=${mkHexColor base03}
        ProgressBarForegroundColor=${mkHexColor base0A}
        ProgressBarBorderColor=${mkHexColor base05}
        MessageBelowAnimation=true

        [boot-up]
        UseEndAnimation=false

        [shutdown]
        UseEndAnimation=false

        [reboot]
        UseEndAnimation=false
      '';

      plymouthThemePackage = pkgs.runCommand "${themeName}-theme" { } ''
        theme_dir="$out/share/plymouth/themes/${themeName}"
        mkdir -p "$theme_dir"
        install -m0644 "${plymouthThemeFile}" "$theme_dir/${themeName}.plymouth"
      '';
    in
    {
      stylix.targets.plymouth.enable = false;

      boot = {
        consoleLogLevel = 0;
        initrd.verbose = false;
        kernelParams = [
          "quiet"
          "splash"
          "udev.log_level=3"
          "rd.udev.log_level=3"
          "vt.global_cursor_default=0"
        ];

        plymouth = {
          enable = true;
          theme = themeName;
          themePackages = [ plymouthThemePackage ];
          logo = lyLogo;
        };
      };

      services.displayManager.sddm.enable = false;
      services.greetd.enable = false;

      services.displayManager.ly = {
        enable = true;
        settings = {
          animation = "colormix";
          colormix_col1 = "0x00${config.lib.stylix.colors.base08}";
          colormix_col2 = "0x00${config.lib.stylix.colors.base0B}";
          colormix_col3 = "0x00${config.lib.stylix.colors.base0A}";
          bigclock = true;
          clear_password = true;
          default_input = "session";
          hide_borders = true;
          shutdown_key = "F1";
          restart_key = "F2";
        };
      };

      services.displayManager.defaultSession = "niri";

    };
}
