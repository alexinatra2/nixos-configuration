import { execFile } from "node:child_process";
import path from "node:path";
import { promisify } from "node:util";
import {
  Action,
  ActionPanel,
  closeMainWindow,
  environment,
  List,
} from "@vicinae/api";

const execFileAsync = promisify(execFile);

const profiles = [
  {
    name: "direct",
    title: "Direct",
    description: "Hardware inputs to PCM inputs; PCM outputs to hardware outputs",
  },
  {
    name: "preamp",
    title: "Preamp",
    description: "Hardware inputs routed to both PCM inputs and hardware outputs",
  },
  {
    name: "stereo-out",
    title: "Stereo Output",
    description: "PCM 1/2 mirrored across hardware outputs 1/3 and 2/4",
  },
  {
    name: "teams",
    title: "Teams",
    description: "Remapped hardware inputs with direct PCM output routing",
  },
] as const;

async function applyProfile(profile: string) {
  await closeMainWindow();
  await execFileAsync("focusrite-profile", [profile]);
}

export default function Profiles() {
  return (
    <List isShowingDetail searchBarPlaceholder="Select Focusrite profile...">
      {profiles.map((profile) => {
        const preview = path.join(
          environment.assetsPath,
          `${profile.name}.jpg`,
        );

        return (
          <List.Item
            key={profile.name}
            title={profile.title}
            subtitle={profile.description}
            detail={
              <List.Item.Detail
                markdown={`![${profile.title} routing](file://${preview})`}
              />
            }
            actions={
              <ActionPanel>
                <Action
                  title="Apply Profile"
                  onAction={() => applyProfile(profile.name)}
                />
              </ActionPanel>
            }
          />
        );
      })}
    </List>
  );
}
