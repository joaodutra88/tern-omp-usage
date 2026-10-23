# Notes for AI coding agents

You are helping someone use, change or report a problem with **tern-omp-usage**, a [Tern](https://stencil.so/tern) window plugin that draws Claude and Codex limits from `omp` in Tern's status line. Read this file before touching the code.

## Map

| File | What lives there |
|---|---|
| `plugin.toml` | Manifest. `id = "omp-usage"`; every command and CSS hook is prefixed `plugin.omp-usage.`; one block, `dashboard`. |
| `window.luau` | Entry point: timers, the refresh and dashboard commands, the CSS, the status formatter, the optional `extras.luau` hook. |
| `host.luau` | Host half: the `dashboard` block (runs `omp usage --history`, draws the cards, `r` refreshes). |
| `history.luau` | The dashboard's data, with no `tern` calls: hourly series per limit and the cost of today, 7 days and the month. |
| `usage.luau` | Everything about usage: runs `omp`, parses its JSON, builds the segments, the `⏳` forecast and the threshold/lock/free toasts. |
| `config.luau` | Finds `omp` (`OMP_USAGE_BIN`, then the copy Tern manages, then `PATH`); settings in `tern.kv` (parts shown, language, work days, red-badge threshold) and the palette commands that change them. |
| `labels.luau` | Every word the plugin shows, one table per language. |
| `update.luau` | Daily GitHub release check, the `⬆` segment and its toast, the one-click reinstall, the toast after an update. |
| `tests/*_test.luau` | Unit: one module against a fake `tern` (canned `omp` replies, a canned GitHub answer); checks what the bar and the toasts say. |
| `tests/integration/` | Integration: `harness.luau` loads both halves like Tern, with a fake clock, Tern's budgets, a Windows-like reinstall and the recorded replies in `fixtures.luau`; scenarios in `plugin_test.luau`. |
| `scripts/check.py` | The gate: plain (unit), `--integration`, `--tern`. CI runs the first two on every pull request. |

## Rules that are easy to break

- **The status formatter has 4 ms.** Tern disables a plugin that goes over. Never run a process, read a file or walk directories inside `tern.chrome.status`; do it in `tern.timer` or a `tern.process.run` callback and cache the result.
- **Timers and callbacks have 50 ms.** Over that, Tern turns off every timer of the plugin until a reload, and the bar freezes. Start one process or request per callback at most; start the next one from its callback, or from another timer. The integration harness fails a change that breaks this.
- **Run installs outside the plugin folder.** `tern.process.run` starts in the plugin's folder by default, and on Windows `tern plugin install --force` can't replace a folder a process is running in: pass `cwd = tern.plugin.data`.
- **Tern's CSS is a subset.** `text-shadow`, `margin-block` and friends are rejected (the check catches them). Style a segment by its title: `#statusline .sl-plugin[title="plugin.omp-usage.<command>"]`, which is why every segment carries a `command` even when it only refreshes.
- **UTF-8.** Strings sent to Tern must stay valid UTF-8. Cut text by characters (`utf8.offset`), never by bytes.
- **Anthropic rate-limits** its usage endpoint below about 5 minutes. Don't poll faster than `FETCH_MS`.
- **Text the user sees** lives in `labels.luau`. Add a key to `en` (and the other languages you can) instead of hard-coding words elsewhere.
- **Settings are read outside the formatter.** `config.load()` reads `tern.kv` at load and on the minute tick; the formatter only reads the cached table.
- **No credentials, one request.** The plugin runs `omp`, plus a daily unauthenticated GET of this repository's latest GitHub release (off with the `updates` part or `OMP_USAGE_NO_UPDATE_CHECK`). Don't add more network calls; anything that needs a token belongs in `omp`, not here.
- **Write only to `tern.plugin.data`.** An install replaces the package folder, and a write inside it reloads the plugin.

## What the user can configure

The palette: `OMP usage: show or hide a part…`, `language…`, `work days per week…`, `red badge threshold…`, `reset settings`, `check for updates`, `update to the latest version`, `what's new` (settings in `tern.kv`, kept across updates). The `OMP_USAGE_BIN` environment variable for the `omp` path and `OMP_USAGE_NO_UPDATE_CHECK=1` to stop the release check; personal segments in an untracked `extras.luau` (shape in the README). Point users there before suggesting a fork.

## Before you propose a change

```sh
python scripts/check.py                # syntax, unit tests, CSS, manifest, changelog
python scripts/check.py --integration  # the whole plugin in a fake Tern (budgets, update, dashboard)
python scripts/check.py --tern         # also reloads the plugin in Tern and reads the log (when Tern is installed)
```

All must end with `all checks passed`. Add a case to `tests/usage_test.luau` when you change what the bar shows, and a scenario to `tests/integration/plugin_test.luau` when a change crosses modules, timers or the update. Fixtures come from real `omp` output: record with `--redact`, then replace every e-mail, account id and org name with fakes. `check.py` fails on any e-mail in `tests/` that isn't `@example.com`; ids and org names are on you.

## When the user hits a bug

Collect these and offer to open the issue for them. Show the text first, and only file it after they agree:

1. `tern plugin list --json`, just the `omp-usage` entry.
2. Lines with `omp-usage` from Tern's log (`%LOCALAPPDATA%\Tern\Logs\tern.log` on Windows).
3. `omp --version`, and whether `omp usage --json -p anthropic` works in a terminal.
4. What the bar shows against what they expected. A screenshot helps.

**Remove emails, account ids, org names and tokens** from `omp usage --json` output before pasting it. That output contains them.

```sh
gh issue create --repo joaodutra88/tern-omp-usage --template bug_report.yml
```

If `gh` can't use the template non-interactively, pass `--title` and `--body` with the same sections as `.github/ISSUE_TEMPLATE/bug_report.yml`.
