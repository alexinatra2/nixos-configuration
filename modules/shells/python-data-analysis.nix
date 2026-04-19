{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      devShells.python-data-analysis = pkgs.mkShell {
        packages = with pkgs; [
          (python3.withPackages (
            ps: with ps; [
              ipython
              jupyter
              matplotlib
              numpy
              pandas
              scipy
              seaborn
            ]
          ))
        ];
      };
    };
}
