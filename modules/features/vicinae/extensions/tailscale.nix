{
  pkgs,
  raycastRevision,
  vicinaeLib,
  ...
}:
{
  installName = "tailscale";
  package = vicinaeLib.mkRayCastExtension {
    name = "tailscale";
    rev = raycastRevision;
    hash = "sha256-Me989vaYwGEYUrdnjdiYoG0nVAs7qfEuvC+C1feNuI0=";
  };
  settings."@samlinville/tailscale".preferences.tailscalePath = pkgs.lib.getExe pkgs.tailscale;
}
