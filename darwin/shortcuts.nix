{
  lib,
  pkgs,
  ...
}:
let
  validModifiers = [
    "cmd"
    "shift"
    "alt"
    "ctrl"
    "fn"
    "hyper"
    "meh"
  ];

  modifierOrder = [
    "fn"
    "ctrl"
    "alt"
    "shift"
    "cmd"
    "hyper"
    "meh"
  ];

  normalizeKeys =
    keys:
    let
      modifiers = builtins.init keys;
      key = builtins.elemAt keys ((builtins.length keys) - 1);
      uniqueModifiers = lib.unique modifiers;
      invalidModifiers = builtins.filter (modifier: !(builtins.elem modifier validModifiers)) uniqueModifiers;
    in
    assert builtins.isList keys;
    assert builtins.length keys > 0;
    assert uniqueModifiers == modifiers;
    assert invalidModifiers == [ ];
    assert builtins.isString key;
    assert key != "";
    assert builtins.match "^[A-Za-z0-9._-]+$" key != null;
    let
      orderedModifiers = builtins.filter (modifier: builtins.elem modifier uniqueModifiers) modifierOrder;
      prefix = lib.concatStringsSep " + " orderedModifiers;
    in
    if prefix == "" then key else "${prefix} - ${key}";

  mkShortcut =
    {
      description ? null,
      keys,
      action,
    }:
    let
      descriptionLine = lib.optionalString (description != null) "# ${description}\n";
    in
    assert builtins.isString action;
    assert lib.strings.trim action != "";
    "${descriptionLine}${normalizeKeys keys} : ${action}";

  mkShortcuts = shortcuts: lib.concatStringsSep "\n\n" (map mkShortcut shortcuts);
in
{
  services.skhd = {
    enable = true;
    config = mkShortcuts [
      {
        description = "Launch Kitty from anywhere with Cmd+Enter.";
        keys = [
          "cmd"
          "return"
        ];
        action = "${pkgs.kitty}/Applications/kitty.app/Contents/MacOS/kitty --single-instance -d ~";
      }
    ];
  };
}
