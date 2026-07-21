{
  bitwardenSopsFile,
  config,
  githubSopsFile,
  lib,
  username,
}:
let
  githubEnabled = githubSopsFile != null;
  bitwardenEnabled = bitwardenSopsFile != null;
  githubTemplateName = "vicinae/github-settings";
  bitwardenTemplateName = "vicinae/bitwarden-settings";
in
{
  settingsImports =
    lib.optional githubEnabled config.sops.templates.${githubTemplateName}.path
    ++ lib.optional bitwardenEnabled config.sops.templates.${bitwardenTemplateName}.path;

  nixosConfig = {
    sops.secrets =
      lib.optionalAttrs githubEnabled {
        "vicinae/github-token" = {
          sopsFile = githubSopsFile;
          owner = username;
          group = "users";
          mode = "0400";
        };
      }
      // lib.optionalAttrs bitwardenEnabled {
        "vicinae/bitwarden-client-id" = {
          sopsFile = bitwardenSopsFile;
          owner = username;
          group = "users";
          mode = "0400";
        };
        "vicinae/bitwarden-client-secret" = {
          sopsFile = bitwardenSopsFile;
          owner = username;
          group = "users";
          mode = "0400";
        };
      };

    sops.templates =
      lib.optionalAttrs githubEnabled {
        ${githubTemplateName} = {
          owner = username;
          group = "users";
          mode = "0400";
          content = builtins.toJSON {
            providers."@knoopx/vicinae-extension-github-0".preferences.personalAccessToken =
              config.sops.placeholder."vicinae/github-token";
          };
        };
      }
      // lib.optionalAttrs bitwardenEnabled {
        ${bitwardenTemplateName} = {
          owner = username;
          group = "users";
          mode = "0400";
          content = builtins.toJSON {
            providers."@jomifepe/bitwarden".preferences = {
              clientId = config.sops.placeholder."vicinae/bitwarden-client-id";
              clientSecret = config.sops.placeholder."vicinae/bitwarden-client-secret";
            };
          };
        };
      };
  };
}
