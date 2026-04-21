{ ... }:
{
  perSystem =
    { pkgs, lib, ... }:
    let
      slidesServeSlidev = pkgs.writeShellApplication {
        name = "slides-serve-slidev";
        runtimeInputs = [ pkgs.slidev-cli ];
        text = ''
          deck="${"1:-slides.md"}"
          exec slidev "$deck"
        '';
      };

      slidesExportSlidev = pkgs.writeShellApplication {
        name = "slides-export-slidev";
        runtimeInputs = [ pkgs.slidev-cli ];
        text = ''
          deck="${"1:-slides.md"}"
          output="${"2:-slides.pdf"}"
          exec slidev export "$deck" --output "$output"
        '';
      };

      slidesPreviewMarp = pkgs.writeShellApplication {
        name = "slides-preview-marp";
        runtimeInputs = [ pkgs.marp-cli ];
        text = ''
          deck="${"1:-slides.md"}"
          exec marp --preview "$deck"
        '';
      };

      slidesExportMarpPdf = pkgs.writeShellApplication {
        name = "slides-export-marp-pdf";
        runtimeInputs = [ pkgs.marp-cli ];
        text = ''
          deck="${"1:-slides.md"}"
          output="${"2:-slides.pdf"}"
          exec marp "$deck" --pdf --allow-local-files --output "$output"
        '';
      };

      slidesExportMarpPptx = pkgs.writeShellApplication {
        name = "slides-export-marp-pptx";
        runtimeInputs = [ pkgs.marp-cli ];
        text = ''
          deck="${"1:-slides.md"}"
          output="${"2:-slides.pptx"}"
          exec marp "$deck" --pptx --allow-local-files --output "$output"
        '';
      };

      slidesExportQuarto = pkgs.writeShellApplication {
        name = "slides-export-quarto";
        runtimeInputs = [ pkgs.quarto ];
        text = ''
          file="${"1:-slides.qmd"}"
          exec quarto render "$file" --to revealjs
        '';
      };
    in
    {
      devShells.slide-creation = pkgs.mkShell {
        packages =
          (with pkgs; [
            slidev-cli
            marp-cli
            quarto
            pandoc
            slidesServeSlidev
            slidesExportSlidev
            slidesPreviewMarp
            slidesExportMarpPdf
            slidesExportMarpPptx
            slidesExportQuarto
          ])
          ++ lib.optionals pkgs.stdenv.isLinux (
            with pkgs;
            [
              onlyoffice-desktopeditors
            ]
          );
      };
    };
}
