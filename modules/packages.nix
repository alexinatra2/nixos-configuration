{
  flake.modules.nixos.packages =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        alacritty
        firefox
        keepassxc
        vlc
        mpv
        thunderbird
        desktop-file-utils
        android-tools
        home-manager
        cacert
      ];

    };

  flake.modules.darwin.packages =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        m-cli # macOS command line interface
      ];
    };

  flake.modules.homeManager.packages =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        cargo
        gcc
        jdk21
        nerd-fonts.jetbrains-mono
        lazydocker
        lazysql
        nixfmt
        nodejs
        pnpm
        ripgrep
        spotify
        unzip
        xclip
      ];
    };
}
