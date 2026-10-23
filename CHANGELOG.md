# Changelog

Every version `plugin.toml` names has a section here. When that version reaches `main`, CI publishes the section as the GitHub release, and installed copies of the plugin show it.

## Unreleased

- A provider omp has no account for is hidden. Signed in to Claude only, the bar used to show a permanent `⬢ Codex ?` and `⚠`.
- Settings from the palette (type `OMP usage`): show or hide each part, language (`en`, `pt-BR`, `es`, `zh-CN`, `ja`), work days per week and the red-badge threshold. They live in `tern.kv`, so an update keeps them.
- Every word lives in `labels.luau`; a language that leaves a key out falls back to English.
- Update notice: once a day the plugin looks at the latest GitHub release. A newer one shows a blue `⬆` badge and one toast; clicking it reinstalls the plugin (`tern plugin install … --force`), keeping your settings and `extras.luau`. After the update a toast names the new version, and **OMP usage: what's new** opens its notes. Hide the `updates` part or set `OMP_USAGE_NO_UPDATE_CHECK=1` to stop checking.
- Alerts: a toast when a Claude or Codex window reaches the red-badge threshold, locks, or frees up again. The first reading after a reload only sets the baseline, so a reload never repeats an alert.
- Forecast: `⏳23m` after the Claude 5h or `wk` bar when, at the average pace since that window opened, it runs out before it resets. It shows from 50% used.
- Dashboard: **OMP usage: dashboard**, or a click on today's tokens or cost, opens a pane with Claude and Codex 5h and weekly usage hour by hour over the last 7 days, and the cost of today, the last 7 days and this month. The plugin now keeps each day's total in `tern.kv`, because `omp stats` only goes back about a day.

## 0.3.1

- Finds the omp that Tern manages on macOS (`~/Library/Application Support/Tern/omp/bin/omp`).
- Shows `✻ Claude ?` and `⬢ Codex ?` instead of a stuck `⟳ …` when omp can't start.

## 0.3.0

- First release: Claude and Codex limits from omp in Tern's status line, a work-week budget, saved resets, and today's tokens and cost.
