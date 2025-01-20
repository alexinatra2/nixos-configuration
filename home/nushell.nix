{
  programs.nushell = {
    enable = true;
    shellAliases = {
      lg = "lazygit";
      ld = "lazydocker";
      open = "xdg-open";
      cd = "z";
    };
    envFile = ''
      $env.FLAKEREF = "/home/alexander/nixos-configuration/"
    '';
    extraConfig = ''
      def tat [] {
         # Get the current directory name without the trailing slash
         let name = (pwd | basename | str replace "\." "")

         # Check if the tmux session exists and attach if found
         let session_exists = (tmux ls 2>&1 | str contains $name)
         if $session_exists {
             tmux attach -t $name
         } else {
             # If a .envrc file exists, use direnv to start tmux session
             if (test -f .envrc) {
                 direnv exec / tmux new-session -s $name
             } else {
                 tmux new-session -s $name
             }
         }
        }

    '';

  };
}
