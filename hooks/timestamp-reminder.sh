#!/bin/sh
# Emits the Timestamp UserPromptSubmit reminder as compact JSON. It carries the
# rules, a stamp for the START of this turn, and the exact command to run for
# the FINISH time on turns that used tools - with the start time baked into
# that command so the script can draw both lines. macOS/Linux counterpart to
# timestamp-reminder.ps1 - see README.md for how to point hooks.json at it.

root=$(cd "$(dirname "$0")" && pwd)
start=$(sh "$root/timestamp-now.sh" --text)
stamp=$(sh "$root/timestamp-now.sh" "$start")
cmd="sh \"$root/timestamp-now.sh\" \"$start\""

msg="Timestamp (per the timestamp skill) runs on EVERY reply with no exceptions - long or short, one-liners and questions back to the user included. The very last thing in the reply, below everything else including the shared skills run box if one is present (the stamp is the postmark, so it comes after the run box), is the stamp: a fenced code block holding exactly the box lines printed by the stamp script, pasted verbatim, nothing added or changed. It shows when this turn STARTED and when you FINISHED writing, in the user's own time zone. Never guess, estimate, or adjust a time. If you used NO tools this turn, paste the start-of-turn stamp below - start and finish are the same to within a minute. If you used ANY tool this turn, run this exact command as your final tool call, immediately before writing the reply, and paste its lines instead (the start time is already inside the command - do not edit it): $cmd . Do not reformat, re-pad, or translate the stamp, and do not add a Timestamp row to the run box - the stamp itself is the evidence. Start-of-turn stamp:
$stamp"

# JSON-escape: backslashes, double quotes, newlines.
esc=$(printf '%s' "$msg" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' | awk 'NR>1{printf "\\n"} {printf "%s", $0}')
printf '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"%s"}}\n' "$esc"
