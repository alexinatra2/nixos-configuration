{ ... }:
{
  flake.nixosModules.teamsMic =
    {
      pkgs,
      ...
    }:
    {
      systemd.user.services.teams-mic-loopback = {
        description = "Teams virtual mic from Scarlett rear inputs";
        after = [
          "pipewire.service"
          "wireplumber.service"
        ];
        wants = [
          "pipewire.service"
          "wireplumber.service"
        ];
        wantedBy = [ "default.target" ];

        serviceConfig = {
          ExecStart = pkgs.writeShellScript "teams-mic-loopback" ''
            exec ${pkgs.pipewire}/bin/pw-loopback \
              --name "Teams Mic" \
              --capture "alsa_input.usb-Focusrite_Scarlett_4i4_USB_D8YWQZ02B2EC38-00.pro-input-0" \
              --playback-props '{"media.class":"Audio/Source","node.description":"Teams Mic","audio.position":["FL","FR"]}' \
              --capture-props '{"stream.dont-remix":true,"audio.position":["AUX2","AUX3"]}'
          '';
          Restart = "on-failure";
          RestartSec = 2;
        };
      };
    };
}
