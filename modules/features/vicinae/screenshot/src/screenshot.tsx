import { execFile } from "node:child_process";
import { promisify } from "node:util";
import {
  Action,
  ActionPanel,
  closeMainWindow,
  Color,
  List,
} from "@vicinae/api";

const execFileAsync = promisify(execFile);

const screenshotActions = [
  {
    title: "Interactive Selection",
    subtitle: "Select an area to capture",
    shortcut: "Print",
    action: "screenshot",
  },
  {
    title: "Focused Screen",
    subtitle: "Capture the screen containing the focused window",
    shortcut: "Ctrl+Print",
    action: "screenshot-screen",
  },
  {
    title: "Focused Window",
    subtitle: "Capture the currently focused window",
    shortcut: "Alt+Print",
    action: "screenshot-window",
  },
] as const;

async function takeScreenshot(action: string) {
  await closeMainWindow();
  await new Promise((resolve) => setTimeout(resolve, 150));
  await execFileAsync("niri", ["msg", "action", action]);
}

export default function Screenshot() {
  return (
    <List searchBarPlaceholder="Choose what to capture...">
      {screenshotActions.map((item) => (
        <List.Item
          key={item.action}
          title={item.title}
          subtitle={item.subtitle}
          accessories={[
            { tag: { value: item.shortcut, color: Color.SecondaryText } },
          ]}
          actions={
            <ActionPanel>
              <Action
                title="Take Screenshot"
                onAction={() => takeScreenshot(item.action)}
              />
            </ActionPanel>
          }
        />
      ))}
    </List>
  );
}
