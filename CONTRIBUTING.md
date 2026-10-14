# Contributing

Issues and pull requests are welcome: bugs, new providers, translations, better colors. If an AI agent is doing the work, have it read [AGENTS.md](AGENTS.md) first.

## Run it locally

```sh
git clone https://github.com/joaodutra88/tern-omp-usage
tern plugin link tern-omp-usage
```

Tern reloads a linked plugin when a file changes. You can also run `tern plugin reload`, then `tern plugin list` to see whether it loaded or was disabled.

## Validate your change

Install the [Luau CLI](https://github.com/luau-lang/luau/releases/latest) (`luau` and `luau-compile` on `PATH`, or set `LUAU_DIR` to their folder), then:

```sh
python scripts/check.py          # syntax, tests, CSS rules Tern rejects, manifest
python scripts/check.py --tern   # also reloads the plugin in your Tern and reads its log
```

Both should end with `all checks passed`. CI runs the first one on every pull request.

If you change what the bar shows, add a case to `tests/usage_test.luau`. It runs `usage.luau` against a fake `tern` with canned `omp` replies, so it needs neither Tern nor omp.

## Things Tern is strict about

- A status formatter that takes over 4 ms gets the plugin disabled. Slow work (processes, file reads) belongs in timers and process callbacks.
- Tern's CSS engine is a subset. `text-shadow` and `margin-block` are rejected; the check script catches the known ones.
- Text sent to Tern must stay valid UTF-8. Cut by characters, not bytes.

## Translations

Add the words to `M.labels` in `usage.luau`, and a `README.<lang>.md` if you like, linked from the language line at the top of each README. If you want an automatic language switch, open an issue first so we agree on how to pick the language.
