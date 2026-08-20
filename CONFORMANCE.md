# Timestamp — porting conformance

The brief for anyone porting Timestamp to another platform (Codex, Grok, Antigravity, or one that doesn't exist yet). This is not the skill. The reference text is [`skills/timestamp/SKILL.md`](skills/timestamp/SKILL.md).

**A port is a translation, not a rewrite.** Translate the mechanics — hook plumbing, manifest format, shell dialect. Keep the meaning. If a rule below is missing from your port, the port is wrong, however good it reads.

## The one rule everything else protects

**The model has no clock.** Every time in the stamp comes from a script running on the user's machine. The model's only job is to paste what the script printed. A port that lets the model produce a time — any time, however plausible — has destroyed the plugin, because the stamp will still *look* right.

## Rules that must survive the port

Any wording. All present.

1. **Every reply, no exceptions.** One-line answers and questions back to the user included. Skipping short turns is exactly how the two times end up identical when they weren't.
2. **Never guess, estimate, adjust, or round a time.** Not "about 21:00", not "a few minutes after the start", not a zone converted in the model's head.
3. **The stamp command runs as the final tool call**, immediately before the reply is written. Fetched any earlier on a long turn, the finish time is really a start time wearing the wrong label.
4. **STARTED comes from the hook's reading** at the moment the user's message landed; **FINISHED comes from the clock at write time.** The hook bakes the start value into the command it hands over, and the model must not edit it — retyping it is the only way a wrong start time can get in.
5. **Paste the script's output verbatim.** No re-padding, no reformatting, no translating the zone label into a city name, no extra lines.
6. **The script draws the box and computes its own padding** — not the model. This is what keeps the edges meeting on every platform. A port that has the model assemble the box will produce crooked boxes eventually.
7. **Seconds, not just minutes.** Minute precision makes every sub-minute turn look instant.
8. **Placement: the postmark.** Last of all — after the answer, after any Purpose Box, and **after** the shared run box. Other skills' rows are the receipt about the machinery; this is the postmark on the envelope, and postmarks go last.
9. **It never adds a row to the run box.** The box at the bottom is the evidence it ran.
10. **The fallback is narrow and must be declared.** Only when no tool can be run at all: paste the start-of-turn stamp and add one plain line saying the finish time is really the start time. Never use it silently, and never because the reply felt too small to bother.

## Free to change — and expected to

- **The shell.** PowerShell, `sh`, Python, whatever the platform can actually run. The output is what must match.
- **Hook and manifest mechanics** — whatever that platform's format is.
- **The box characters and the date format**, if the platform's display needs it — provided the script still measures its own padding and both lines still line up.
- **Wording and voice** throughout.

## Never change these

- **The time is script-sourced or it does not appear.** There is no third option. Inventing a plausible time is the most dangerous failure this plugin has, precisely because it looks correct.
- **The start value passes through untouched** from hook to command to output.
- **The fallback is always declared** when used.

## Time zone

The stamp uses the machine's own zone. `TIMESTAMP_TZ` overrides it — a Windows time zone id on Windows, an IANA zone elsewhere. **An unrecognised value must fall back to the machine's zone rather than fail**: a broken stamp on every reply is a far worse outcome than a stamp in the wrong zone.

## Wiring checklist for a new platform

- [ ] Plugin manifest in that platform's own folder and format — never share a folder with another platform's manifest.
- [ ] Hook path uses **that platform's own root variable**. `${CLAUDE_PLUGIN_ROOT}` is Claude Code's. If you do not know the platform's variable, find out or use an absolute path — do not borrow another platform's.
- [ ] The reminder hook emits valid single-line JSON, verified by running it.
- [ ] The reminder hook works out its own location, so the command it hands over points at its own copy of the stamp script.
- [ ] The start value survives quoting all the way to the command line — it contains spaces, so it must stay quoted.
- [ ] `.ps1` and `.sh` both present where the platform runs on both Windows and Unix, and **both print a byte-identical box** for the same inputs.
- [ ] Uneven line lengths still pad to a square box — test with a long zone offset such as `UTC-5:30`.
- [ ] No discoverable skill or hook left at the repo root, where two platforms could both load it.
- [ ] Version set in that platform's manifest — and **bumped on every change**, or installers will not pick the change up.

## Checking a port

Structural checks are automatable: the two scripts print identical output, the box lines are equal width, the hook emits valid JSON, and the handed-over command runs unmodified.

The rules above are **not** automatable, and should not be turned into exact-phrase greps. They say "any wording" on purpose; a grep for a phrase forces one wording and defeats the point of a port. A person or a reviewing agent reads the port against this list. That reading is the check.

The decisive test, worth running on the weakest model the platform offers: **hand it a deliberately stale start time and a task that takes real time.** A correct port keeps the stale value as STARTED and fetches a genuinely current FINISHED. A broken one pastes the stale stamp whole — which is the exact bug this plugin was rewritten twice to kill.
