# Prints the Timestamp stamp - a small closed box with the current local time.
# Honours TIMESTAMP_TZ (a Windows time zone id, e.g. "GMT Standard Time") if set;
# otherwise uses the machine's own time zone. Box padding is computed here so the
# model pastes it verbatim and the edges always line up.

$now = Get-Date
$tz  = [System.TimeZoneInfo]::Local
if ($env:TIMESTAMP_TZ) {
    try {
        $tz  = [System.TimeZoneInfo]::FindSystemTimeZoneById($env:TIMESTAMP_TZ)
        $now = [System.TimeZoneInfo]::ConvertTime($now, $tz)
    } catch { }
}
$off = $tz.GetUtcOffset($now)
$sign = if ($off.TotalMinutes -lt 0) { '-' } else { '+' }
$h = [Math]::Abs($off.Hours); $m = [Math]::Abs($off.Minutes)
$zone = if ($m -eq 0) { "UTC$sign$h" } else { "UTC$sign$h`:$('{0:00}' -f $m)" }

$line = "FINISHED  " + $now.ToString('HH:mm') + "  " + $now.ToString('ddd d MMM yyyy', [System.Globalization.CultureInfo]::InvariantCulture) + "  " + $zone
$bar  = [string]::new([char]0x2500, $line.Length + 2)
$top  = ([string][char]0x250C) + $bar + ([string][char]0x2510)
$mid  = ([string][char]0x2502) + ' ' + $line + ' ' + ([string][char]0x2502)
$bot  = ([string][char]0x2514) + $bar + ([string][char]0x2518)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$top + "`n" + $mid + "`n" + $bot
