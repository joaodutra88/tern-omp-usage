## What changes

<!-- What the bar shows or does differently. Before/after screenshots of the status line help. -->

## Checks

CI runs `unit` and then `integration` (Linux, Windows, macOS); both must pass before a merge.

- [ ] `python scripts/check.py` and `python scripts/check.py --integration` end with `all checks passed`
- [ ] `python scripts/check.py --tern` passes on my machine, or I don't have Tern here
- [ ] New words the bar shows are in `labels.luau`
- [ ] A case in `tests/usage_test.luau` if the bar output changed, a scenario in `tests/integration/plugin_test.luau` if the change crosses modules, timers or the update
- [ ] A line under the next version in `CHANGELOG.md` if users will notice
