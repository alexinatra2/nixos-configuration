{ config, ... }:
{
  plugins.web-devicons.enable = true;

  plugins.treesitter = {
    enable = true;
    highlight.enable = true;
    indent.enable = true;
    grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
      typescript
      tsx
      javascript
      lua
      json
      html
      css
      nix
      rust
    ];
  };

  plugins.treesitter-textobjects.enable = true;
}
