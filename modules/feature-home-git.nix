{
  flake.modules.homeManager.git = {
    programs.git = {
      enable = true;
      settings = {
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
      };
    };
  };
}
