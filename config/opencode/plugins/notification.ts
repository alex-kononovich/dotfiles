import type { Plugin, PluginInput } from "@opencode-ai/plugin";

const DELAY_MS = 60_000;

const ASKED_EVENTS = new Set(["permission.asked", "question.asked"]);
const REPLIED_EVENTS = new Set(["permission.replied", "question.replied", "question.rejected"]);

type PluginEvent = {
    type: string;
    properties?: { id?: string; requestID?: string };
};

function notify($: PluginInput["$"], message: string) {
    return $`grrr --appId OpenCode --title OpenCode --reactivate ${message}`;
}

export const NotificationPlugin: Plugin = async ({ $ }) => {
    const pendingTimers = new Map<string, ReturnType<typeof setTimeout>>();

    return {
        event: async ({ event }: { event: PluginEvent }) => {
            if (ASKED_EVENTS.has(event.type)) {
                const requestID = event.properties?.id;
                if (!requestID) return;
                const timer = setTimeout(async () => {
                    pendingTimers.delete(requestID);
                    await notify($, "Response needed");
                }, DELAY_MS);
                pendingTimers.set(requestID, timer);
            }

            if (REPLIED_EVENTS.has(event.type)) {
                const requestID = event.properties?.requestID;
                if (!requestID) return;
                const timer = pendingTimers.get(requestID);
                if (timer) {
                    clearTimeout(timer);
                    pendingTimers.delete(requestID);
                }
            }

            if (event.type === "session.error") {
                await notify($, "Session error occurred");
            }
        },
    };
};
