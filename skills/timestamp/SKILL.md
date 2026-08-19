---
name: timestamp
description: Use on every reply, in every session, with no exceptions — ends each response with a small stamp box showing the time the reply was finished, in the user's own time zone, taken from a script on their machine and never guessed. For anyone who loses track of when a chat last moved, or who needs to see at a glance whether a reply is from five minutes ago or five hours ago.
---

# Timestamp

*A postmark on every reply: the time you finished, in the reader's own zone, never guessed.*

## The one idea

The model has no clock. Left to itself it will either leave the time off or, worse, make one up. So the time comes from a script on the user's machine, in the user's time zone, and the model's only job is to paste it — exactly — as the very last thing in the reply. A small closed box, same shape every time, so the eye finds it without reading:

```
┌─────────────────────────────────────────┐
│ FINISHED  20:58  Wed 19 Aug 2026  UTC+7 │
└─────────────────────────────────────────┘
```

That is the whole skill. Everything below is about getting the time right and putting the box in the right place.

## Where the time comes from

Two sources, and the hook tells you which to use:

1. **No tools used this turn** — paste the *start-of-turn stamp* the hook gave you. You started writing the moment the prompt landed, so the start time is the finish time to within a minute.
2. **Any tool used this turn** — the turn may have run for minutes or hours. Run the stamp command the hook gave you **as your final tool call, immediately before writing the reply**, and paste its three lines. That is the real finish time.

The command is always the same file: `hooks/timestamp-now.ps1` (Windows) or `hooks/timestamp-now.sh` (macOS/Linux) inside this plugin. The hook hands you the absolute path so there is nothing to look up.

**Never guess, estimate, adjust, or round a time.** Not "about 21:00", not "a few minutes after the start stamp", not a time converted in your head to another zone. If you cannot run the command, paste the start-of-turn stamp and say in one line that it is the start time. A stamp that might be wrong is worse than no stamp, because the reader will trust it.

## The shape

The script draws the box, including the padding, so the edges always meet. Paste its three lines inside a fenced code block and change nothing:

- No emoji, no label above it, no sentence after it.
- No re-padding "to make it look neater" — the script already measured it.
- No translating the zone label (`UTC+7`) into a city or a name.
- No rows, no extra lines.

## Placement

The stamp is the **very last thing in the reply** — after the answer, after any Purpose Box, and after the shared **run box** (the fenced receipt other skills use to declare that they ran). The run box is the receipt; the stamp is the postmark on the envelope. Postmarks go last.

The stamp does **not** add a row to the run box. The box at the bottom is the evidence it ran.

## Time zone

The script uses the machine's own time zone, which is the user's. To stamp in a different zone (travelling, or a team in one zone reading a machine in another), set the environment variable `TIMESTAMP_TZ` before starting Claude Code:

- Windows: a Windows time zone id, e.g. `GMT Standard Time`, `SE Asia Standard Time`
- macOS/Linux: an IANA zone, e.g. `Europe/London`, `Asia/Bangkok`

If the value is not recognised the script falls back to the machine's zone rather than failing.

## Quick reference

| Situation | What to paste |
|---|---|
| Conversational reply, no tools | The start-of-turn stamp from the hook |
| Any tool call this turn | Run the stamp command last, paste its output |
| Stamp command fails | Start-of-turn stamp + one line saying it is the start time |
| Other skills printed a run box | Stamp goes **below** the run box |
| Purpose Box present | Answer → Purpose Box → run box → stamp |
| A different zone is wanted | Set `TIMESTAMP_TZ`; never convert by hand |

## Red flags — you are doing it wrong

| Signal | What it means |
|---|---|
| The stamp time is not something a script printed this turn | You guessed. Run the command or use the start stamp. |
| You used tools but pasted the start-of-turn stamp | On a long turn that is minutes or hours wrong. Run the command. |
| The box edges do not meet | You edited the lines. Paste exactly what the script printed. |
| The stamp is above the run box | Move it. It is the last thing in the reply. |
| You added a TIMESTAMP row to the run box | Remove it. |
| You skipped it because the reply was one line | Never skip. |

## Common mistakes

- **Inventing a plausible time.** The most dangerous failure, because it looks right. The rule is absolute: the time comes from the script or it does not appear.
- **Running the command first, not last.** If you fetch the time at the start of a long turn, it is the start time wearing a FINISHED label. Make it the final tool call.
- **"Tidying" the box.** The script counted the characters. Any edit breaks the edges.
- **Converting zones in your head.** The script already stamped in the right zone. If the user wants another, that is `TIMESTAMP_TZ`, not arithmetic.
