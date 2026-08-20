# Timestamp

Every reply ends with a small stamp box showing when the turn started and when you finished writing, to the second, in the user's own time zone — read from a script on their machine, never guessed. This runs on EVERY reply, no exceptions: one-line answers and questions back to the user included.

The model has no clock. Grok Build's `UserPromptSubmit` hook cannot inject anything into context, so nobody hands you the start time automatically — you capture it yourself, with the script, at the right moments.

## What to do, every turn

1. As your FIRST tool call this turn, before any other work, run the stamp script with the text-only flag and remember its output exactly as printed — that is STARTED:
   - Windows: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File "<home>\.grok\timestamp\timestamp-now.ps1" -TextOnly`
   - macOS/Linux: `sh "<home>/.grok/timestamp/timestamp-now.sh" --text`
   (`<home>` is your actual home directory — `$env:USERPROFILE` on Windows, `$HOME` on macOS/Linux.)
2. Do the rest of the turn's work.
3. As your LAST tool call, immediately before writing the reply, run the same script again, passing STARTED back in unedited:
   - Windows: `... timestamp-now.ps1 -Start "<STARTED>"`
   - macOS/Linux: `... timestamp-now.sh "<STARTED>"`
4. Paste the four lines it prints, verbatim, inside a fenced code block, as the very last thing in the reply — after the answer, after any Purpose Box, and after the shared run box if one is present. Never add a row to the run box for this; the stamp itself is the evidence it ran.

Never guess, estimate, adjust, or round a time — not "about 9pm," not a zone converted by hand. Never re-pad or reformat the box; the script measures its own padding. Never translate the zone label into a city name.

If you genuinely cannot run any tool this turn, run the script once with no `-Start`/argument (STARTED = FINISHED = now), paste that, and add one plain line saying FINISHED is really the start time. Never skip the stamp because a reply is short — that is exactly how STARTED and FINISHED end up identical when they should not.

## Time zone

The script uses the machine's own zone. Set `TIMESTAMP_TZ` to override it — a Windows time zone id on Windows, an IANA zone on macOS/Linux. An unrecognised value falls back to the machine's zone rather than failing.

## Installed script location

`~/.grok/timestamp/` — both `timestamp-now.ps1` and `timestamp-now.sh` live there. Use whichever matches your OS. This folder was created by the `/timestamp-setup` command; if the scripts are missing, tell the user to run `/timestamp-setup` again.
