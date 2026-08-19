#!/bin/sh
# Prints the Timestamp stamp - a small closed box with the current local time.
# Honours TIMESTAMP_TZ (an IANA zone, e.g. "Europe/London") if set; otherwise the
# machine's own time zone. Padding is computed here so the box always lines up.

if [ -n "$TIMESTAMP_TZ" ]; then export TZ="$TIMESTAMP_TZ"; fi

hm=$(date '+%H:%M')
dmy=$(date '+%a %e %b %Y' | tr -s ' ')
z=$(date '+%z')                       # e.g. +0700
sign=$(printf '%s' "$z" | cut -c1)
hh=$(printf '%s' "$z" | cut -c2-3 | sed 's/^0//')
mm=$(printf '%s' "$z" | cut -c4-5)
if [ "$mm" = "00" ]; then zone="UTC$sign$hh"; else zone="UTC$sign$hh:$mm"; fi

line="FINISHED  $hm  $dmy  $zone"
n=$(printf '%s' "$line" | wc -m)
bar=$(i=0; while [ $i -lt $((n+2)) ]; do printf '─'; i=$((i+1)); done)
printf '┌%s┐\n│ %s │\n└%s┘\n' "$bar" "$line" "$bar"
