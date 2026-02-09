# Shared configuration between NixOS and nix-darwin
{
  config,
  pkgs,
  inputs,
  ...
}:
{
  # Nix configuration shared across systems
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    optimise.automatic = true;
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Shared environment configuration
  environment = {
    # Common session variables
    variables = {
      EDITOR = "nvim";
      TERMINAL = "kitty";
    };

    # This attribute only exists on NixOS
    sessionVariables = pkgs.lib.mkIf (pkgs.stdenv.isLinux) {
      EDITOR = "nvim";
      TERMINAL = "kitty";
    };

    # Common system packages
    systemPackages = with pkgs; [
      git
      vim
      wget
    ];
  };

  # Timezone - can be overridden per host
  time.timeZone = "Europe/Berlin";

  # Common program settings
  programs.zsh.enable = true;
}
