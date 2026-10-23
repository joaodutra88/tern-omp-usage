-- Claude and Codex usage from omp in Tern's status line (usage.luau). See README.md.
local usage = require("./usage")
local FETCH_MS = 5 * 60 * 1000 -- Anthropic usage endpoint answers 429 below ~5 min
local TICK_MS = 60 * 1000

-- Tern's app may not inherit the shell PATH, so prefer the omp that Tern itself manages.
local function managed_omp(): string?
	local paths: { string } = {}
	local local_app = tern.getenv("LOCALAPPDATA")
	if local_app then
		table.insert(paths, local_app .. "\\Tern\\omp\\bin\\omp.exe")
	end
	local home = tern.getenv("HOME")
	if home then
		table.insert(paths, home .. "/Library/Application Support/Tern/omp/bin/omp")
		table.insert(paths, (tern.getenv("XDG_DATA_HOME") or home .. "/.local/share") .. "/Tern/omp/bin/omp")
	end
	for _, p in paths do
		if tern.fs.exists(p) then
			return p
		end
	end
	return nil
end

local OMP = tern.getenv("OMP_USAGE_BIN") or managed_omp() or "omp"

local function every(ms: number, fn: () -> ())
	local function loop()
		fn()
		tern.timer(ms, loop)
	end
	loop()
end

local function hidden(id: string, run: () -> ())
	tern.command({
		id = id,
		title = "Status line: " .. id,
		available = function()
			return false
		end,
		run = run,
	})
end

tern.command({
	id = "refresh",
	title = "OMP usage: refresh Claude and Codex limits",
	run = function()
		usage.fetch(true)
	end,
})
usage.init(OMP, hidden)

-- window_start doesn't fire again after `tern plugin reload`; a load-time timer covers both.
tern.timer(0, function()
	every(FETCH_MS, usage.fetch)
	every(FETCH_MS, usage.fetch_today)
	tern.timer(TICK_MS, function()
		every(TICK_MS, tern.chrome.refresh) -- countdown moves without new data
	end)
end)

tern.css("statusline", [[
/* Tern spaces plugin segments with a flex gap; zero it and let each segment set its own margin. */
#statusline > .sl-plugins { gap: 0 !important; }
#statusline > .sl-plugins > .sl-plugin { margin-left: 6px; }
#statusline .sl-plugin[title^="plugin.omp-usage."] { margin: 0 0 0 6px; padding: 0; }
#statusline .sl-plugin[title="plugin.omp-usage.claude"] { margin-left: 16px; padding-left: 12px;
  border-left: 1px solid rgb(255 255 255 / 10%); color: #d97757; font-weight: 600; }
#statusline .sl-plugin[title="plugin.omp-usage.codex"] { margin-left: 16px; padding-left: 12px;
  border-left: 1px solid rgb(255 255 255 / 10%); color: #3b82f6; font-weight: 700; }
#statusline .sl-plugin[title="plugin.omp-usage.today"] { margin-left: 16px; padding-left: 12px;
  border-left: 1px solid rgb(255 255 255 / 10%); color: #fb923c; font-weight: 600; }
#statusline .sl-plugin[title="plugin.omp-usage.cost"] { margin-left: 8px; padding: 0 6px; border-radius: 4px;
  color: #4ade80; background: rgb(74 222 128 / 12%); font-weight: 700; }
#statusline .sl-plugin[title="plugin.omp-usage.credits"] { color: #c084fc; }
#statusline .sl-plugin[title="plugin.omp-usage.slack-ok"] { margin-left: 10px; padding: 0 6px; border-radius: 4px;
  color: #4ade80; background: rgb(74 222 128 / 12%); font-weight: 700; }
#statusline .sl-plugin[title="plugin.omp-usage.slack-bad"] { margin-left: 10px; padding: 0 6px; border-radius: 4px;
  color: #f87171; background: rgb(239 68 68 / 18%); font-weight: 700; animation: omppulse 1.2s ease-in-out infinite; }
#statusline .sl-plugin[title="plugin.omp-usage.reset"] { color: rgb(255 255 255 / 45%); }
#statusline .sl-plugin[title="plugin.omp-usage.reset-soon"] { color: #4ade80; font-weight: 600; }
#statusline .sl-plugin[title="plugin.omp-usage.locked"] { margin-left: 16px; color: #fff; background: #b91c1c;
  padding: 0 6px; border-radius: 4px; font-weight: 700; animation: omppulse 0.9s ease-in-out infinite; }
#statusline .sl-plugin[title^="plugin.omp-usage.dot-"] { margin-left: 0; }
#statusline .sl-plugin[title="plugin.omp-usage.dot-1"] { margin-left: 6px; color: #22c55e; }
#statusline .sl-plugin[title="plugin.omp-usage.dot-2"] { color: #a3e635; }
#statusline .sl-plugin[title="plugin.omp-usage.dot-3"] { color: #facc15; }
#statusline .sl-plugin[title="plugin.omp-usage.dot-4"] { color: #f97316; }
#statusline .sl-plugin[title="plugin.omp-usage.dot-5"] { color: #ef4444; }
#statusline .sl-plugin[title="plugin.omp-usage.empty"] { color: rgb(255 255 255 / 14%); }
#statusline .sl-plugin[title^="plugin.omp-usage.dot-"] + .sl-plugin[title="plugin.omp-usage.empty"] { margin-left: 0; }
#statusline .sl-plugin[title="plugin.omp-usage.pct-1"] { color: #22c55e; }
#statusline .sl-plugin[title="plugin.omp-usage.pct-2"] { color: #a3e635; }
#statusline .sl-plugin[title="plugin.omp-usage.pct-3"] { color: #facc15; }
#statusline .sl-plugin[title="plugin.omp-usage.pct-4"] { color: #f97316; font-weight: 600; }
#statusline .sl-plugin[title="plugin.omp-usage.pct-crit"] { color: #fff; font-weight: 700; background: #dc2626;
  padding: 0 4px; border-radius: 3px; animation: omppulse 1.2s ease-in-out infinite; }
@keyframes omppulse { 50% { opacity: 0.35; } }
]])

-- Optional local file for personal segments; absent in a fresh install.
local has_extras, extras = pcall(require, "./extras")
if has_extras then
	extras.init(hidden, every)
end

tern.chrome.status(function(pane)
	local out = {}
	if has_extras then
		extras.segments(out, pane)
	end
	usage.segments(out)
	return out
end)
