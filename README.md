# Timestamp

A Claude Code plugin that puts a small stamp at the bottom of every reply - when the turn started and when Claude finished writing, in your own time zone - so you can see at a glance when any chat last moved and how long the last turn took.

```
┌─────────────────────────────────────────┐
│ STARTED   20:58  Wed 19 Aug 2026  UTC+7 │
│ FINISHED  21:01  Wed 19 Aug 2026  UTC+7 │
└─────────────────────────────────────────┘
```

## What it does

Ships a skill (`timestamp`) plus a `UserPromptSubmit` hook that fires on every turn. The important design choice: **the model never makes the time up.** It has no clock, so left alone it would either skip the time or guess. Instead, a tiny script on your machine prints the stamp, and Claude's only job is to paste it, exactly, as the last thing in the reply.

- The hook reads your clock when your message lands, gives Claude a stamp for the *start* of the turn, and the exact command to fetch the finish - with that start time already baked into the command.
- If Claude answered without using any tools, start and finish are the same to within a minute, so it pastes the start stamp (both lines already filled in).
- If Claude used tools - a build that ran for twenty minutes, say - it runs the stamp command as its final step, right before writing. The script draws STARTED from the hook's reading and FINISHED from the clock now. Claude never types a time.
- The script draws the box and measures the padding itself, so the edges always line up. Claude does not reformat it, and it does not edit the command.
- It runs on every reply, one-liners included. It sits at the very bottom - below the answer, below the Purpose Box if you use it, and below the shared run box that the other skills print. The stamp is the postmark; postmarks go last.
- It never adds a row to the run box. The stamp itself is the evidence it ran.

## Your time zone

The stamp uses your machine's time zone, which is normally exactly what you want. To stamp in a different zone, set `TIMESTAMP_TZ` in your environment before starting Claude Code:

- Windows: a Windows time zone id - `GMT Standard Time`, `SE Asia Standard Time`, `Eastern Standard Time`
- macOS/Linux: an IANA zone - `Europe/London`, `Asia/Bangkok`, `America/New_York`

An unrecognised value falls back to the machine's zone rather than breaking anything.

## Why it exists

When you are running several chats at once, two questions come up constantly and the answers are nowhere on screen: "when did this one last move?" and "how long did that take?" A fixed little box in a fixed place answers both in one glance - and because the times come from your machine, not the model's imagination, you can trust them.

## Install

In any Claude Code session:

```
/plugin marketplace add naamdog/timestamp
/plugin install timestamp@timestamp
```

Start a new session (or restart Claude Code) so the skill and hook load. Manage it any time with `/plugin list`, `/plugin disable timestamp`, or `/plugin uninstall timestamp@timestamp`.

## macOS / Linux note

The hook ships two versions of every script. Both emit the same JSON and the same stamp:

- `hooks/timestamp-reminder.ps1` + `hooks/timestamp-now.ps1` - Windows (PowerShell). Wired up in `hooks/hooks.json` by default.
- `hooks/timestamp-reminder.sh` + `hooks/timestamp-now.sh` - macOS/Linux (POSIX `sh`).

If you're on macOS or Linux, switch `hooks/hooks.json` over to the `.sh` script:

1. Make them executable once (they're tracked with the executable bit set, but if that's ever lost): `chmod +x hooks/*.sh`
2. Edit `hooks/hooks.json` and replace the PowerShell `command` value with:
   ```
   "\"${CLAUDE_PLUGIN_ROOT}/hooks/timestamp-reminder.sh\""
   ```

The reminder script works out its own location and hands Claude the matching `.sh` command with the start time already in it, so nothing else needs changing. `hooks.json` can't hold comments, which is why this note lives here instead.

## Sits well with

Built in the same shape as [purpose-box](https://github.com/naamdog/purpose-box), [cheap-trick](https://github.com/naamdog/cheap-trick), [simple-language](https://github.com/naamdog/simple-language) and [world-class-results](https://github.com/naamdog/world-class-results). Each one stands alone. When they run together the bottom of a reply reads: Purpose Box, then the shared run box, then the Timestamp.

## License

MIT - see [LICENSE](LICENSE).
