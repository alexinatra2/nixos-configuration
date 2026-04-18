{ self, inputs, ... }:
{
  flake.modules.homeManager.image-editing =
    { pkgs, ... }:
    {
      home.packages = [
        inputs.comfyui-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
}
