#!/bin/sh
# Prints the Timestamp stamp - a small closed box with STARTED and FINISHED
# times in the machine's local zone (or TIMESTAMP_TZ, an IANA zone, if set).
# Padding is computed here so the box always lines up.
#
#   timestamp-now.sh                -> box, STARTED = FINISHED = now
#   timestamp-now.sh "<text>"       -> box, STARTED = <text>, FINISHED = now
#   timestamp-now.sh --text         -> just the time text for now, no box
#
# <text> is the time text this script itself prints with --text, e.g.
# "20:58:12  Wed 19 Aug 2026  UTC+7". The reminder hook captures it at the start
# of the turn and hands it back in the command it gives the model.

if [ -n "$TIMESTAMP_TZ" ]; then export TZ="$TIMESTAMP_TZ"; fi

hm=$(date '+%H:%M:%S')
dmy=$(date '+%a %e %b %Y' | tr -s ' ')
z=$(date '+%z')                       # e.g. +0700
sign=$(printf '%s' "$z" | cut -c1)
hh=$(printf '%s' "$z" | cut -c2-3 | sed 's/^0//')
mm=$(printf '%s' "$z" | cut -c4-5)
if [ "$mm" = "00" ]; then zone="UTC$sign$hh"; else zone="UTC$sign$hh:$mm"; fi
nowtext="$hm  $dmy  $zone"

if [ "$1" = "--text" ]; then printf '%s\n' "$nowtext"; exit 0; fi

start="$1"
if [ -z "$start" ]; then start="$nowtext"; fi
l1="STARTED   $start"
l2="FINISHED  $nowtext"
n1=$(printf '%s' "$l1" | wc -m); n2=$(printf '%s' "$l2" | wc -m)
w=$n1; if [ "$n2" -gt "$w" ]; then w=$n2; fi
pad() { s="$1"; while [ "$(printf '%s' "$s" | wc -m)" -lt "$w" ]; do s="$s "; done; printf '%s' "$s"; }
l1=$(pad "$l1"); l2=$(pad "$l2")
bar=$(i=0; while [ $i -lt $((w+2)) ]; do printf '─'; i=$((i+1)); done)
printf '┌%s┐\n│ %s │\n│ %s │\n└%s┘\n' "$bar" "$l1" "$l2" "$bar"
