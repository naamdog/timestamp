#!/bin/sh
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
# name), update the invocation_num extraction below to match - the guard logic itself
# (act only when the count is 0) does not change.
#
# This script never prints the box itself and is never the thing the model pastes. It only
# writes the plain start-of-turn time text to ".turn-start" next to this script, using the
# co-located timestamp-now.sh. The rules file tells the model to read that file for STARTED
# and to run timestamp-now.sh again, with that value, as its last tool call of the turn, to
# produce FINISHED.

root=$(cd "$(dirname "$0")" && pwd)

payload=$(cat)
invocation_num=$(printf '%s' "$payload" | grep -o '"invocationNum"[[:space:]]*:[[:space:]]*[0-9]*' | grep -o '[0-9]*$')
if [ -z "$invocation_num" ]; then invocation_num=0; fi

if [ "$invocation_num" -ne 0 ]; then exit 0; fi

sh "$root/timestamp-now.sh" --text > "$root/.turn-start"
exit 0
