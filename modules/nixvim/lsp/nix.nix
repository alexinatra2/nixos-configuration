{
  pkgs,
  lib,
  ...
}:
{
  lsp.servers.nixd = {
    enable = true;
    config = {
      formatting.command = [ "${lib.getExe pkgs.nixfmt}" ];
    };
  };
}
