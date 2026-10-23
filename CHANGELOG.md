# Changelog

Every version `plugin.toml` names has a section here. When that version reaches `main`, CI publishes the section as the GitHub release, and installed copies of the plugin show it.

## Unreleased

- A provider omp has no account for is hidden. Signed in to Claude only, the bar used to show a permanent `⬢ Codex ?` and `⚠`.

## 0.3.1

- Finds the omp that Tern manages on macOS (`~/Library/Application Support/Tern/omp/bin/omp`).
- Shows `✻ Claude ?` and `⬢ Codex ?` instead of a stuck `⟳ …` when omp can't start.

## 0.3.0

- First release: Claude and Codex limits from omp in Tern's status line, a work-week budget, saved resets, and today's tokens and cost.
