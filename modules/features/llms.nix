{ self, inputs, ... }:
{
  flake.modules.homeManager.llms =
    {
      config,
      pkgs,
      ...
    }:
    {
      home.packages = [
        pkgs.python313Packages.huggingface-hub
        pkgs.heretic
      ];

      sops.secrets."llms/huggingface/token" = { };

      sops.templates."llms/huggingface/token-file" = {
        content = config.sops.placeholder."llms/huggingface/token";
        mode = "0400";
      };

      home.sessionVariables.HF_TOKEN_PATH = config.sops.templates."llms/huggingface/token-file".path;
    };
}
