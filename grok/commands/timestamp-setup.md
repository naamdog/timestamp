# /timestamp-setup

Run these steps now, in order, without asking for confirmation first.

1. Locate this plugin's own installed folder (the `grok/` package folder this command file lives two levels under — i.e. `grok/commands/timestamp-setup.md`, so the package root is its parent's parent). From there, find the sibling `claude-code/` folder at the repository root (one level up from `grok/`).
2. Create the folder `~/.grok/rules/` if it does not already exist.
3. Copy this plugin's `rules/timestamp.md` (found at the package root, sibling to `commands/`) into `~/.grok/rules/timestamp.md`. If a file already exists at that path, overwrite it in place — do not create a duplicate under a different name.
4. Create the folder `~/.grok/timestamp/` if it does not already exist.
5. Copy `claude-code/hooks/timestamp-now.ps1` and `claude-code/hooks/timestamp-now.sh` (at the repository root found in step 1) into `~/.grok/timestamp/`, overwriting any existing copies there. Preserve the executable bit on `timestamp-now.sh` if the filesystem supports it.
6. Confirm to the user, in one line, that Timestamp is installed and will take effect starting next session.

Do not skip step 5 — without it the rules file has no script to run and the stamp cannot be script-sourced.
