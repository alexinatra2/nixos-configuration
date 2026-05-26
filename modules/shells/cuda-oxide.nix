{ ... }:
{
  perSystem =
    {
      pkgs,
      lib,
      system,
      ...
    }:
    let
      llvmPkgs = pkgs.llvmPackages_21;
      cudaPkgs = pkgs.cudaPackages;
    in
    lib.optionalAttrs (system == "x86_64-linux") {
      devShells.cuda-oxide = pkgs.mkShell {
        packages = [
          pkgs.cmake
          pkgs.git
          pkgs.just
          pkgs.pkg-config
          pkgs.python3
          pkgs.rustup
          cudaPkgs.cudatoolkit
          cudaPkgs.cuda_gdb
          llvmPkgs.clang
          llvmPkgs.libclang
          llvmPkgs.llvm
        ];

        CUDA_HOME = "${cudaPkgs.cudatoolkit}";
        CUDA_OXIDE_LLC = "${llvmPkgs.llvm}/bin/llc";
        CUDA_PATH = "${cudaPkgs.cudatoolkit}";
        LIBCLANG_PATH = "${llvmPkgs.libclang.lib}/lib";
      };
    };
}
