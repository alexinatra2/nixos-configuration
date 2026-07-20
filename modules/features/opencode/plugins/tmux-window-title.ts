import type { Plugin } from "@opencode-ai/plugin"

type Session = {
  id: string
  parentID?: string
  title: string
}

const normalizeTitle = (title: string) =>
  title
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 60)
    .replace(/-+$/g, "")

export const TmuxWindowTitle: Plugin = async ({ $, client }) => {
  if (!process.env.TMUX) return {}

  let windowId: string
  let originalName: string

  try {
    windowId = (await $`tmux display-message -p '#{window_id}'`.quiet()).text().trim()
    originalName = (
      await $`tmux display-message -p -t ${windowId} '#{window_name}'`.quiet()
    )
      .text()
      .trim()
  } catch {
    return {}
  }

  const sessions = new Map<string, Session>()
  let activeSessionId: string | undefined
  let currentName = originalName

  const rename = async (title: string) => {
    const name = normalizeTitle(title)
    if (!name || name === currentName) return

    try {
      await $`tmux rename-window -t ${windowId} -- ${name}`.quiet()
      currentName = name
    } catch {
      // Losing the tmux server must not interrupt the OpenCode session.
    }
  }

  const activate = async (sessionId: string) => {
    activeSessionId = sessionId
    let session = sessions.get(sessionId)

    if (!session) {
      try {
        const response = await client.session.get({ path: { id: sessionId } })
        session = response.data as Session | undefined
      } catch {
        return
      }
    }

    if (!session || session.parentID) return
    sessions.set(session.id, session)
    await rename(session.title)
  }

  return {
    "chat.message": async ({ sessionID }) => {
      await activate(sessionID)
    },
    event: async ({ event }) => {
      if (event.type !== "session.updated") return

      const session = event.properties.info
      if (session.parentID) return

      sessions.set(session.id, session)
      if (session.id === activeSessionId) await rename(session.title)
    },
    dispose: async () => {
      if (currentName === originalName) return

      try {
        await $`tmux rename-window -t ${windowId} -- ${originalName}`.quiet()
      } catch {
        // The tmux server may already have exited.
      }
    },
  }
}
