# Rendering of the `settings` submodule into opencode's snake_case JSON shape.
{ lib }:

let
  # Fixed camelCase -> snake_case renames applied at controlled structural levels.
  # A "*" key renames inside every element of an attrset of objects. Free-form
  # objects (provider/agent/model `options`, lsp `initialization`) are passed
  # through verbatim.
  keyMap = {
    settings = {
      logLevel = "log_level";
      disabledProviders = "disabled_providers";
      enabledProviders = "enabled_providers";
      smallModel = "small_model";
      defaultAgent = "default_agent";
      subagentDepth = "subagent_depth";
      toolOutput = {
        _name = "tool_output";
        maxLines = "max_lines";
        maxBytes = "max_bytes";
      };
      attachment = {
        image = {
          autoResize = "auto_resize";
          maxWidth = "max_width";
          maxHeight = "max_height";
          maxBase64Bytes = "max_base64_bytes";
        };
      };
      agent = {
        "*" = {
          topP = "top_p";
        };
      };
      provider = {
        "*" = {
          models = {
            "*" = {
              releaseDate = "release_date";
              toolCall = "tool_call";
              cost = {
                cacheRead = "cache_read";
                cacheWrite = "cache_write";
                contextOver200k = "context_over_200k";
              };
            };
          };
        };
      };
      mcp = {
        "*" = {
          oauth = {
            clientId = "client_id";
            clientSecret = "client_secret";
            callbackPort = "callback_port";
            redirectUri = "redirect_uri";
          };
        };
      };
    };
  };

  rename =
    map: key:
    let
      m = map.${key} or null;
    in
    if builtins.isAttrs m && builtins.hasAttr "_name" m then
      m._name
    else if builtins.isString m then
      m
    else
      key;
  applyMap =
    map: value:
    if builtins.isAttrs value then
      lib.mapAttrs' (k: v: {
        name = rename map k;
        value =
          if builtins.hasAttr k map && builtins.isAttrs map.${k} then
            applyMap map.${k} v
          else if builtins.hasAttr "*" map then
            applyMap map."*" v
          else
            v;
      }) value
    else
      value;

  # Recursively drop null, empty attrs, and empty lists.
  clean =
    value:
    if builtins.isAttrs value then
      let
        filtered = lib.filterAttrs (_: v: !(isUseless v)) (lib.mapAttrs (_: clean) value);
      in
      if filtered == { } then null else filtered
    else if builtins.isList value then
      let
        filtered = lib.filter (v: !(isUseless v)) (builtins.map clean value);
      in
      if filtered == [ ] then null else filtered
    else
      value;

  isUseless = v: v == null || (builtins.isAttrs v && v == { }) || (builtins.isList v && v == [ ]);

  renderSettings =
    settings:
    let
      cleaned = clean (applyMap keyMap.settings settings);
      withPlugins =
        if builtins.hasAttr "plugin" cleaned && cleaned.plugin != null then
          cleaned
          // {
            plugin = builtins.map (
              e:
              if builtins.isAttrs e then
                [
                  e.name
                  (e.options or { })
                ]
              else
                e
            ) cleaned.plugin;
          }
        else
          cleaned;
    in
    builtins.toJSON withPlugins;
in
{
  inherit
    renderSettings
    clean
    applyMap
    keyMap
    ;
}
