# Roadmap

What shipped, what comes next, and the rules every change follows. Ideas and votes go to [Discussions](https://github.com/joaodutra88/tern-omp-usage/discussions); anything marked **good first issue** in [Issues](https://github.com/joaodutra88/tern-omp-usage/issues) is a fine place to start.

## Shipped in 0.4.0

- **Releases from the manifest.** Bumping `version` in `plugin.toml` on `main` publishes the GitHub release, with that version's section of `CHANGELOG.md` as the notes. `scripts/check.py` fails when the version has no section.
- **Update notice and one-click update.** A daily, unauthenticated look at the latest release; a blue `⬆` and one toast per new version; a click reinstalls the plugin and keeps settings and `extras.luau`; a toast after the update and **OMP usage: what's new**. Off with the `updates` part or `OMP_USAGE_NO_UPDATE_CHECK=1`.
- **Settings without editing code.** Palette commands for the parts shown, the language (`en`, `pt-BR`, `es`, `zh-CN`, `ja`), work days per week and the red-badge threshold, kept in `tern.kv` so updates keep them.
- **A provider you don't use is hidden** instead of showing `?` and `⚠` all the time.
- **Alerts**: a toast when a window reaches the red-badge threshold, locks, or frees up again.
- **Forecast**: `⏳23m` when, at the pace since the window opened, it runs out before its reset.
- **Dashboard**: 7 days of Claude and Codex usage hour by hour, and the cost of today, the last 7 days and this month.

## Next

- [ ] A toast when a saved usage-limit reset becomes available.
- [ ] Make the "reset soon" window (30 min) a setting, next to the red-badge threshold.
- [ ] New features start turned off and the "updated" toast offers to turn them on, so an update never changes someone's bar by surprise.
- [ ] A dashboard row for every other provider `omp usage` reports (Gemini, Copilot…), not only Claude and Codex.
- [ ] More languages: copy `en` in `labels.luau`, translate, open a pull request.
- [ ] Rendered images of the dashboard and the alert toast for the README, from canned `omp` replies like the other images.

## Rules for every change

- The status formatter gets 4 ms: no process, file or `tern.kv` read inside `tern.chrome.status`.
- Tern's CSS is a subset; `scripts/check.py` catches the properties it rejects. Strings must be valid UTF-8.
- Every word the plugin shows lives in `labels.luau`.
- The only network request is the daily release check, with no token, and it can be turned off.
- `python scripts/check.py` (and `--tern`, when you have Tern) passes, and every new behavior gets a case in `tests/`.
