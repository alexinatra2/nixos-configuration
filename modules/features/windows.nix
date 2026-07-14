{ self, inputs, ... }:
{
  flake.nixosModules.windows =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      pkgs-stable = import inputs.nixpkgs-stable {
        system = pkgs.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };
    in
    {
      environment.systemPackages = with pkgs-stable; [
        wineWow64Packages.stable
        winetricks
        (bottles.override {
          removeWarningPopup = true;
        })
        qpwgraph
        pavucontrol
        vulkan-tools
        mesa-demos
        pciutils
        usbutils
      ];

    };
}
