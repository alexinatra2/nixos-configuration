{
  pkgs,
  raycastRevision,
  vicinaeLib,
  ...
}:
{
  installName = "search-npm";
  package = vicinaeLib.mkRayCastExtension {
    name = "search-npm";
    rev = raycastRevision;
    hash = "sha256-mjkjxe/eWKoY9w2nUJ/ELXIHIQ+w+RQAN3AD0LNyRkE=";
  };
  settings."@mrmartineau/search-npm".preferences.defaultCopyAction = "pnpm";
}
