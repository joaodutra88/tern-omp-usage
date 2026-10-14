-- Runs usage.luau against a fake `tern` with canned `omp` replies and checks what the bar draws.
-- Run: luau tests/usage_test.luau (from the repository root, or via scripts/check.py).

local now_ms = os.time() * 1000
local DAY = 86400 * 1000

local replies: { [string]: any } = {}

local function reply(argv: { string }): string
	return table.concat(argv, " ", 2)
end

local fake = {
	timer = function(_ms: number, fn: () -> ())
		fn()
	end,
	chrome = { refresh = function() end },
	json = {
		decode = function(key: string)
			return assert(replies[key], "no canned reply for: " .. key)
		end,
	},
	process = {
		run = function(argv: { string }, opts, done)
			local cb = if type(opts) == "function" then opts else done
			cb({ status = 0, stdout = reply(argv) })
		end,
	},
}
local usage = require("../usage")
-- Why: the luau CLI freezes _G; the module's own environment stays writable and is read at call time.
local env: any = getfenv(usage.fetch)
env.tern = fake

local function claude(five: number, week: number, week_reset: number, extra: { any }?)
	local limits = {
		{ id = "anthropic:5h", amount = { usedFraction = five }, window = { resetsAt = now_ms + 90 * 60 * 1000 } },
		{ id = "anthropic:7d", amount = { usedFraction = week }, window = { resetsAt = week_reset } },
	}
	for _, l in extra or {} do
		table.insert(limits, l)
	end
	return { reports = { { limits = limits, resetCredits = { availableCount = 1 } } } }
end

local codex = {
	reports = {
		{
			limits = {
				{ id = "openai-codex:primary", window = { resetsAt = now_ms + DAY } },
				{ id = "openai-codex:secondary", window = { resetsAt = now_ms + 3 * DAY } },
			},
			resetCredits = { availableCount = 2 },
		},
		{ limits = {}, resetCredits = { availableCount = 1 } },
	},
	capacity = {
		["openai-codex"] = {
			{ window = "5h", accounts = 2, usedAccounts = 0.5 },
			{ window = "7d", accounts = 2, usedAccounts = 1 },
		},
	},
}

local function render(claude_reply): (string, { [string]: boolean })
	replies["usage --json -p anthropic"] = claude_reply
	replies["usage --json -p openai-codex"] = codex
	replies["stats --json"] = { timeSeries = { { timestamp = now_ms, tokens = 1500000, cost = 12.4 } } }
	usage.fetch()
	usage.fetch_today()
	local out = {}
	usage.segments(out)
	local texts, commands = {}, {}
	for _, s in out do
		table.insert(texts, s.text)
		if s.command then
			commands[s.command] = true
		end
	end
	return table.concat(texts, " "), commands
end

local function expect(cond: boolean, msg: string, text: string)
	if not cond then
		error(msg .. "\n  bar: " .. text, 2)
	end
end

-- The 7d window starting right now leaves at most one weekday unlocked (20%), so 0% used is never over budget.
local text, cmd = render(claude(0.4, 0, now_ms + 7 * DAY))
expect(text:find("✻ Claude", 1, true) ~= nil, "Claude group missing", text)
expect(text:find("40%", 1, true) ~= nil, "5h percentage missing", text)
expect(text:find("📅 left", 1, true) ~= nil, "budget should be 'left' at 0% weekly use", text)
expect(text:find("Fable", 1, true) == nil, "Fable must stay hidden when the plan has no Fable window", text)
expect(text:find("reset 1h", 1, true) ~= nil, "5h reset countdown missing", text)
expect(text:find("✦1", 1, true) ~= nil, "Claude saved reset missing", text)
expect(text:find("⬢ Codex", 1, true) ~= nil, "Codex group missing", text)
expect(text:find("×2", 1, true) ~= nil, "Codex account count missing", text)
expect(text:find("25%", 1, true) ~= nil, "Codex 5h should be usedAccounts/accounts = 25%", text)
expect(text:find("✦3", 1, true) ~= nil, "Codex saved resets should sum over accounts", text)
expect(text:find("🔥 2M tokens", 1, true) ~= nil, "today's tokens missing", text)
expect(text:find("💸 $12", 1, true) ~= nil, "today's cost missing", text)
expect(cmd["plugin.omp-usage.locked"] == nil, "nothing is at 100%, no lockout badge", text)

-- 100% of the week with only today unlocked: over budget, and Claude is locked.
text, cmd = render(claude(0.5, 1, now_ms + 7 * DAY, {
	{ id = "anthropic:7d:fable", amount = { usedFraction = 0.1 }, window = { resetsAt = now_ms + 7 * DAY } },
}))
expect(text:find("📅 over", 1, true) ~= nil, "budget should be 'over' at 100% weekly use", text)
expect(cmd["plugin.omp-usage.slack-bad"] == true, "over budget uses the red style", text)
expect(text:find("CLAUDE LOCKED", 1, true) ~= nil, "lockout badge missing at 100%", text)
expect(text:find("Fable", 1, true) ~= nil, "Fable shows when the plan has it", text)
expect(cmd["plugin.omp-usage.pct-crit"] == true, "100% uses the critical style", text)

-- Labels are the translation point.
usage.labels.left = "sobra"
text = render(claude(0, 0, now_ms + 7 * DAY))
expect(text:find("📅 sobra", 1, true) ~= nil, "labels should be overridable", text)

print("usage_test: ok")
