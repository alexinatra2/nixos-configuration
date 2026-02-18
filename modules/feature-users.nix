# User configuration
{ ... }:
let
  # Default username for Linux systems
  defaultLinuxUsername = "alexander";

  # Default username for macOS systems
  defaultDarwinUsername = "alexanderholzknecht";

  # Common user groups for NixOS
  nixosUserGroups = [
    "wheel" # For sudo access
    "adbusers" # For Android development
    "docker" # For Docker access
    "networkmanager" # For network management
    "realtime" # For audio/real-time processes
    "audio" # For audio access
  ];
in
{
  flake.modules.nixos.users =
    { pkgs, ... }:
    {
      # Enable common shells
      programs.zsh.enable = true;
      programs.bash.enable = true;

      # Default user shell
      users.defaultUserShell = pkgs.zsh;

      # Define NixOS user with additional groups
      users.users.${defaultLinuxUsername} = {
        isNormalUser = true;
        extraGroups = nixosUserGroups;
      };
    };

  # Darwin doesn't need user creation (managed by macOS)
  # but we set the primary user
  flake.modules.darwin.users = {
    system.primaryUser = defaultDarwinUsername;
  };

  # Home Manager doesn't create system users
  flake.modules.homeManager.users =
    { lib, ... }:
    {
      home.username = lib.mkDefault defaultLinuxUsername;
    };
}
