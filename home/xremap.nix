{
  inputs,
  ...
}:
{
  imports = [
    inputs.xremap-flake.homeManagerModules.default
  ];

  services.xremap = {
    enable = true;
    withKDE = true;

    config = {
      modmap = [
        {
          name = "Global";
          remap = {
            "CapsLock" = "Esc";
          };
        }
      ];
    };
  };
}
