# Prints the Timestamp stamp - a small closed box with STARTED and FINISHED
# times in the machine's local zone (or TIMESTAMP_TZ, a Windows time zone id,
# if set). Padding is computed here so the model pastes it verbatim and the
# edges always line up.
#
#   timestamp-now.ps1                 -> box, STARTED = FINISHED = now
#   timestamp-now.ps1 -Start "<text>" -> box, STARTED = <text>, FINISHED = now
#   timestamp-now.ps1 -TextOnly       -> just the time text for now, no box
#
# <text> is the time text this script itself prints with -TextOnly, e.g.
# "20:58:12  Wed 19 Aug 2026  UTC+7". The reminder hook captures it at the start
# of the turn and hands it back in the command it gives the model.

param(
    [string]$Start = '',
    [switch]$TextOnly
)

$now = Get-Date
$tz  = [System.TimeZoneInfo]::Local
if ($env:TIMESTAMP_TZ) {
    try {
        $tz  = [System.TimeZoneInfo]::FindSystemTimeZoneById($env:TIMESTAMP_TZ)
        $now = [System.TimeZoneInfo]::ConvertTime($now, $tz)
    } catch { }
}
$off  = $tz.GetUtcOffset($now)
$sign = if ($off.TotalMinutes -lt 0) { '-' } else { '+' }
$h = [Math]::Abs($off.Hours); $m = [Math]::Abs($off.Minutes)
$zone = if ($m -eq 0) { "UTC$sign$h" } else { "UTC$sign$h`:$('{0:00}' -f $m)" }

$nowText = $now.ToString('HH:mm:ss') + "  " + $now.ToString('ddd d MMM yyyy', [System.Globalization.CultureInfo]::InvariantCulture) + "  " + $zone

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
if ($TextOnly) { $nowText; exit 0 }

if (-not $Start) { $Start = $nowText }
$l1 = "STARTED   " + $Start
$l2 = "FINISHED  " + $nowText
$w  = [Math]::Max($l1.Length, $l2.Length)
$l1 = $l1.PadRight($w); $l2 = $l2.PadRight($w)

$bar = [string]::new([char]0x2500, $w + 2)
$V   = [string][char]0x2502
$top = ([string][char]0x250C) + $bar + ([string][char]0x2510)
$r1  = $V + ' ' + $l1 + ' ' + $V
$r2  = $V + ' ' + $l2 + ' ' + $V
$bot = ([string][char]0x2514) + $bar + ([string][char]0x2518)
$top + "`n" + $r1 + "`n" + $r2 + "`n" + $bot
