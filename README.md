**English** | [Português](README.pt-BR.md) | [Español](README.es.md) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md)

# tern-omp-usage

[![check](https://github.com/joaodutra88/tern-omp-usage/actions/workflows/check.yml/badge.svg)](https://github.com/joaodutra88/tern-omp-usage/actions/workflows/check.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/joaodutra88/tern-omp-usage?style=flat)](https://github.com/joaodutra88/tern-omp-usage/stargazers)

A [Tern](https://stencil.so/tern) status-line plugin for [omp](https://omp.sh) users. It keeps your Claude and Codex subscription limits, this week's spending budget and today's tokens and cost on screen, in one line, with no panel to open.

![Claude and Codex usage in the Tern status line](assets/statusline.png)

## What it answers

Everything stays in the status line, so the answers are on screen while you work:

- **Can I afford a heavy run today?** A work-week budget: each weekday unlocks 20% of the weekly quota, and a holiday's share carries over.
- **What did today cost?** Tokens and API-price cost since midnight, across every provider omp tracks.
- **Do I have a reset saved?** Saved usage-limit resets for Claude and Codex.
- **Claude and Codex side by side**, both read through omp, with nothing new to sign in to.

## What each part means

| Looks like | Meaning |
|---|---|
| <img src="assets/seg-window.png" height="28" alt="5h window"> | Usage of one window: 5h, week (`wk`), and Fable when your plan has it. Each dot keeps its own color, green to red, and the percentage takes the color of the last dot reached. At 80% the percentage turns into a pulsing red badge. |
| <img src="assets/seg-reset.png" height="28" alt="reset countdown"> | Time until the Claude 5h window resets. Turns green when it is under 30 min and the 5h window is at 80% or more, meaning relief is close. |
| <img src="assets/seg-credits.png" height="28" alt="saved resets"> | Usage-limit resets you have saved. |
| <img src="assets/seg-budget.png" height="28" alt="work-week budget"> | Work-week budget. Each Monday-to-Friday day of the current 7-day window unlocks 20% of the weekly quota. `left` is quota unlocked and not spent yet. `over` (pulsing red) means you are spending ahead of the week. |
| <img src="assets/seg-codex.png" height="28" alt="Codex"> | Codex. `×2` is the number of linked accounts, and the windows show the share of accounts used up. |
| <img src="assets/seg-today.png" height="28" alt="today's tokens and cost"> | Tokens and API-price cost since local midnight, all providers, from `omp stats`. Cache reads count as tokens, so most of this number is cache. |
| <img src="assets/seg-refresh.png" height="28" alt="refresh"> | Refresh now. Clicking any usage segment does the same. |

## How it looks as the week goes

These were rendered from canned `omp` replies, so you can see states that don't happen every day.

**Quiet morning.** Everything green, plenty of budget.

![calm](assets/state-calm.png)

**Usage climbing.** A `↑` appears when a window rose 3 points or more since the last reading, 5 minutes earlier.

![rising](assets/state-rising.png)

**Hot 5h window.** At 86% the percentage becomes a red badge, and the reset turns green because relief is 21 minutes away.

![hot](assets/state-hot.png)

**Ahead of the week.** 65% of the week used with only 40% unlocked: `over 25%` pulses until the next weekday catches up.

![over budget](assets/state-over.png)

**Locked.** A window at 100% shows a pulsing badge with the time until it frees up and your saved resets.

![locked](assets/state-locked.gif)

## Install

```sh
tern plugin install https://github.com/joaodutra88/tern-omp-usage
```

You need `omp` signed in to Anthropic and/or OpenAI Codex, so `omp usage` works in a terminal. The plugin uses the omp that Tern manages (`%LOCALAPPDATA%\Tern\omp\bin\omp.exe`) and falls back to `omp` on `PATH`. If Tern's daemon can't find it, set `OMP_USAGE_BIN` to the full path.

### Install with your AI agent

Paste this into omp, Claude Code, Codex or any agent that can run commands:

```text
Install the Tern plugin https://github.com/joaodutra88/tern-omp-usage for me.
1. Check `omp usage --json -p anthropic` (or `-p openai-codex`) works. If it doesn't, help me sign in with omp first.
2. Run `tern plugin install https://github.com/joaodutra88/tern-omp-usage`.
3. Run `tern plugin list --json` and confirm `omp-usage` has status "ready".
4. If it isn't ready, read the lines containing `omp-usage` in Tern's log
   (`%LOCALAPPDATA%\Tern\Logs\tern.log` on Windows) and the repo's AGENTS.md, then tell me what is wrong.
5. Explain what each part of the status line means, using the README.
```

## What it runs and what it touches

The plugin makes no network requests and reads no credentials. It only runs omp:

| Command | When |
|---|---|
| `omp usage --json -p anthropic` | Every 5 min. Anthropic's usage endpoint answers 429 below about 5 min. |
| `omp usage --json -p openai-codex` | Every 5 min |
| `omp stats --json` | Every 5 min |
| `omp usage invalidate` | When you click a segment, to skip omp's cache |

It writes nothing to disk. The status formatter only reads values cached by those calls, because Tern gives a formatter 4 ms.

## Configuration

| Where | Name | Default |
|---|---|---|
| `usage.luau` | `DAILY` | `0.20`, quota unlocked per weekday |
| `usage.luau` | `TREND_STEP` | `0.03`, rise that earns the `↑` |
| `usage.luau` | `M.labels` | The words the bar shows (`left`, `over`, `LOCKED`, `tokens`) |
| `window.luau` | `FETCH_MS` | 5 min |
| environment | `OMP_USAGE_BIN` | Path to `omp` when Tern can't find it |

Colors are plain CSS at the bottom of `window.luau`. Each segment is `#statusline .sl-plugin[title="plugin.omp-usage.<name>"]`.

### In your language

Every word the bar shows lives in `M.labels` at the top of `usage.luau`, so translating is a one-line change. Pull requests adding a language are welcome.

### Your own segments

If an `extras.luau` file sits next to `window.luau`, the plugin loads it. Git ignores it, so personal segments never reach the repository:

```luau
local M = {}
function M.init(hidden, every) end -- register commands, timers, CSS
function M.segments(out, pane) end -- insert segments before the usage ones
return M
```

## Contributing

This is open source under MIT: use it, fork it, change it, ship it. Issues and pull requests are open to everyone.

- `python scripts/check.py` validates syntax, tests, CSS and the manifest. CI runs the same thing. Add `--tern` to also reload the plugin in your Tern and read its log.
- Using an AI agent? Point it at [AGENTS.md](AGENTS.md). It explains the rules that are easy to break and how to file a clean bug report for you.
- More in [CONTRIBUTING.md](CONTRIBUTING.md).

## Star history

[![Star History Chart](https://api.star-history.com/svg?repos=joaodutra88/tern-omp-usage&type=Date)](https://star-history.com/#joaodutra88/tern-omp-usage&Date)
