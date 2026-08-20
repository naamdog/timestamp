# PreInvocation hook for Timestamp. Antigravity's PreInvocation event fires before EVERY
# model call, including each tool-loop step inside a single turn - not just once per turn.
# If this script captured a fresh "start of turn" reading on every firing, STARTED would
# keep resetting mid-turn and the final stamp would lie about how long the turn actually
# took. So this script MUST act only on the first model call of the turn: the event payload
# carries a 0-indexed invocationNum, and this script writes the start stamp only when
# invocationNum is 0, doing nothing (a silent no-op) on every later step of the same turn.
#
# ASSUMPTION (not independently verified against the Antigravity binary, unlike
# ${PLUGIN_ROOT} for Codex): this script expects the PreInvocation payload as JSON on
# stdin, containing an "invocationNum" field, e.g. {"invocationNum":0}. If Antigravity's
# actual contract differs (a CLI argument, an environment variable, a different field
# name), update the $invocationNum extraction below to match - the guard logic itself
# (act only when the count is 0) does not change.
#
# This script never prints the box itself and is never the thing the model pastes. It only
# writes the plain start-of-turn time text to ".turn-start" next to this script, using the
# co-located timestamp-now.ps1. The rules file tells the model to read that file for
# STARTED and to run timestamp-now.ps1 again, with that value, as its last tool call of the
# turn, to produce FINISHED.

param()

$root = $PSScriptRoot

$invocationNum = 0
try {
    $payload = [Console]::In.ReadToEnd()
    if ($payload) {
        $json = $payload | ConvertFrom-Json
        if ($null -ne $json.invocationNum) { $invocationNum = [int]$json.invocationNum }
    }
} catch {
    # Payload missing or not parseable JSON - treat as the first call rather than silently
    # dropping the start stamp for the whole turn.
    $invocationNum = 0
}

if ($invocationNum -ne 0) { exit 0 }

$nowScript = Join-Path $root 'timestamp-now.ps1'
$startFile = Join-Path $root '.turn-start'
$startText = & $nowScript -TextOnly
[System.IO.File]::WriteAllText($startFile, $startText)
exit 0
