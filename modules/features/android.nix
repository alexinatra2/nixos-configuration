{ self, inputs, ... }:
{
  flake.nixosModules.android =
    {
      pkgs,
      ...
    }:
    {
      users.users."alexander".extraGroups = [
        "kvm"
        "adbusers"
      ];
      environment.systemPackages = with pkgs; [
        android-tools
      ];
    };
}
