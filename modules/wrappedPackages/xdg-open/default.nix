{ ... }:
{
  flake.wrappers.xdg-open =
    {
      lib,
      pkgs,
      wlib,
      ...
    }:
    {
      imports = [ wlib.modules.default ];

      config = {
        package = lib.mkDefault pkgs.handlr;
        exePath = "bin/handlr";
        binName = "xdg-open";
        addFlag = [ "open" ];
      };
    };
}
