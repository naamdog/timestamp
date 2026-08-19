# Emits the Timestamp UserPromptSubmit reminder as compact JSON. It carries the
# rules, a stamp for the START of this turn, and the exact command to run for
# the FINISH time on turns that used tools - with the start time baked into
# that command so the script can draw both lines. Windows (PowerShell) version;
# see timestamp-reminder.sh for macOS/Linux, and README.md for how to switch.

$root  = $PSScriptRoot.Replace('\', '/')
$now   = Join-Path $PSScriptRoot 'timestamp-now.ps1'
$start = & $now -TextOnly
$stamp = & $now -Start $start
$cmd   = 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' + $root + '/timestamp-now.ps1" -Start "' + $start + '"'

$msg = "Timestamp (per the timestamp skill) runs on EVERY reply with no exceptions - long or short, one-liners and questions back to the user included. The very last thing in the reply, below everything else including the shared skills run box if one is present (the stamp is the postmark, so it comes after the run box), is the stamp: a fenced code block holding exactly the box lines printed by the stamp script, pasted verbatim, nothing added or changed. It shows when this turn STARTED and when you FINISHED writing, to the second, in the user's own time zone. Never guess, estimate, or adjust a time. On EVERY turn - even a one-line conversational reply - run this exact command as your final tool call, immediately before writing the reply, and paste its lines (the start time is already inside the command - do not edit it): " + $cmd + " . Only if you genuinely cannot run any tool this turn, paste the start-of-turn stamp below instead and add one plain line saying FINISHED is really the start time. Do not reformat, re-pad, or translate the stamp, and do not add a Timestamp row to the run box - the stamp itself is the evidence. Start-of-turn stamp:`n" + $stamp

@{hookSpecificOutput = @{hookEventName = 'UserPromptSubmit'; additionalContext = $msg}} | ConvertTo-Json -Compress -Depth 4
