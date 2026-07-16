{ self, inputs, ... }:
{
  flake.nixosModules.git =
    {
      pkgs,
      ...
    }:
    {
      environment.systemPackages = [ pkgs.delta ];

      programs.git = {
        enable = true;
        config = {
          user = {
            name = "alexinatra2";
            email = "a.holzknecht@gmx.de";
          };

          alias = {
            s = "status";
            c = "commit";
            ca = "commit -a";
            hist = "log --oneline --graph --decorate --all";
            undo = "reset --soft HEAD~1";
          };

          core.pager = "delta";
          core.untrackedCache = true;
          diff.tool = "delta";
          feature.manyFiles = true;
          difftool = {
            prompt = false;
            delta.cmd = "delta --side-by-side --line-numbers \"$LOCAL\" \"$REMOTE\"";
          };

          merge.conflictStyle = "zdiff3";
        };
      };
    };

}
