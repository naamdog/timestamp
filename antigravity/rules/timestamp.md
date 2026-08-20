<!-- Activation: Always On -->

# Timestamp

Every reply ends with a small stamp box showing when the turn started and when you finished writing, to the second, in the user's own time zone — read from a script on their machine, never guessed. This runs on EVERY reply, no exceptions: one-line answers and questions back to the user included.

The model has no clock. A `PreInvocation` hook installed with this plugin fires at the start of every turn and writes the start time to a fixed file for you automatically — you do not run anything to get STARTED, you only read it. You do have to run the script yourself once, at the end, to get FINISHED.

## What to do, every turn

1. As your LAST tool call, immediately before writing the reply, read the file `.turn-start` inside this plugin's `hooks/` folder (next to `timestamp-now.ps1` / `timestamp-now.sh`). Its entire contents is STARTED — the moment this turn began. Do not edit or retype it.
2. In that same final step, run the stamp script, passing that value back in unedited:
   - Windows: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File "<plugin-hooks-folder>/timestamp-now.ps1" -Start "<STARTED>"`
   - macOS/Linux: `sh "<plugin-hooks-folder>/timestamp-now.sh" "<STARTED>"`
   (`<plugin-hooks-folder>` is this plugin's own `hooks/` folder — the same one `.turn-start` came from.)
3. Paste the four lines it prints, verbatim, inside a fenced code block, as the very last thing in the reply — after the answer, after any Purpose Box, and after the shared run box if one is present. Never add a row to the run box for this; the stamp itself is the evidence it ran.

Never guess, estimate, adjust, or round a time — not "about 9pm," not a zone converted by hand. Never re-pad or reformat the box; the script measures its own padding. Never translate the zone label into a city name.

If `.turn-start` is missing, or you genuinely cannot run any tool this turn, run the script once with no `-Start`/argument (STARTED = FINISHED = now), paste that, and add one plain line saying FINISHED is really the start time. Never skip the stamp because a reply is short — that is exactly how STARTED and FINISHED end up identical when they should not.

## Time zone

The script uses the machine's own zone. Set `TIMESTAMP_TZ` to override it — a Windows time zone id on Windows, an IANA zone on macOS/Linux. An unrecognised value falls back to the machine's zone rather than failing.

## Why you only run the script once

Unlike a platform with no hook support at all, this plugin's `PreInvocation` hook fires before every model call in the turn and captures STARTED itself the first time it fires — guarded so later tool-loop steps in the same turn don't overwrite it. That is why you never need to fetch a start time yourself: it is already sitting in `.turn-start` by the time you read it.
