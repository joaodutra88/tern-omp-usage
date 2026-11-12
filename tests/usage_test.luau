-- Runs usage.luau against a fake `tern` with canned `omp` replies and checks what each widget shows.
-- Run: luau tests/usage_test.luau (from the repository root, or via scripts/check.py).

local now_ms = os.time() * 1000
local DAY = 86400 * 1000

local replies: { [string]: any } = {}
local spawn_fails = false

local function reply(argv: { string }): string
	return table.concat(argv, " ", 2)
end

local store: { [string]: any } = {}
local widgets: { [string]: any } = {}
local sheets: { [string]: string } = {}

local toasts: { { string } } = {}
local window_cx = {
	toast = function(_self, level: string, text: string, sub: string?)
		table.insert(toasts, { level, text, sub or "" })
	end,
}

local fake = {
	kv = {
		get = function(key: string)
			return store[key]
		end,
		set = function(key: string, value: any)
			store[key] = value
		end,
	},
	timer = function(_ms: number, fn: () -> ())
		fn()
	end,
	chrome = {
		refresh = function() end,
		widget = function(id: string, spec: any)
			assert(string.match(id, "^[a-z][a-z0-9-]*$") and #id <= 32, "bad widget id " .. id)
			assert(type(spec.name) == "string" and type(spec.render) == "function", id .. " needs a name and render")
			widgets[id] = spec
		end,
	},
	css = function(name: string, source: string)
		sheets[name] = source
	end,
	json = {
		decode = function(key: string)
			return assert(replies[key], "no canned reply for: " .. key)
		end,
	},
	process = {
		run = function(argv: { string }, opts, done)
			if spawn_fails then
				error("tern.process.run omp: No such file or directory (os error 2)")
			end
			local cb = if type(opts) == "function" then opts else done
			cb({ status = 0, stdout = reply(argv) }, window_cx)
		end,
	},
}
local usage = require("../usage")
local config = require("../config")
local history = require("../history")
-- Why: the luau CLI freezes _G; each module's own environment stays writable and is read at call time.
for _, f in { usage.fetch, config.load, history.name } do
	local env: any = getfenv(f)
	env.tern = fake
end
config.load()
usage.widgets()

local t = os.date("*t") :: any
local midnight_ms = (os.time() - (t.hour * 3600 + t.min * 60 + t.sec)) * 1000

local function claude(five: number, week: number, week_reset: number, extra: { any }?, credits: any?)
	local limits = {
		-- 30 s past 1h30m, so a second ticking during the test still reads "1h30m".
		{ id = "anthropic:5h", amount = { usedFraction = five }, window = { resetsAt = now_ms + 90 * 60 * 1000 + 30000 } },
		{ id = "anthropic:7d", amount = { usedFraction = week }, window = { resetsAt = week_reset } },
	}
	for _, l in extra or {} do
		table.insert(limits, l)
	end
	return { reports = { { limits = limits, resetCredits = credits or { availableCount = 1 } } } }
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

local stats = {
	overall = { avgTokensPerSecond = 78.9, avgTtft = 2770, cacheRate = 0.99, cacheSavings = 0.89, firstTimestamp = now_ms - DAY },
	timeSeries = {
		{ timestamp = midnight_ms - 3600000, tokens = 9000000, cost = 80, requests = 900 },
		{ timestamp = now_ms, tokens = 1500000, cost = 12.4, requests = 120 },
	},
}

-- Every widget's view after one fetch round, and all their texts in one line.
local function render(claude_reply, codex_reply: any?): ({ [string]: any }, string)
	replies["usage --json -p anthropic"] = claude_reply
	replies["usage --json -p openai-codex"] = codex_reply or codex
	replies["stats --json"] = stats
	usage.fetch()
	usage.fetch_today()
	local views, texts = {}, {}
	for id, spec in widgets do
		local v = spec.render(nil)
		views[id] = v
		if v then
			assert(type(v.text) == "string", id .. " shows no text")
			table.insert(texts, v.text)
		end
	end
	table.sort(texts)
	return views, table.concat(texts, " | ")
end

local function expect(cond: any, msg: string, text: string?)
	if not cond then
		error(msg .. "\n  got: " .. tostring(text), 2)
	end
end

local function has(s: string?, part: string): boolean
	return s ~= nil and string.find(s, part, 1, true) ~= nil
end

-- The CSS rule that paints one limit widget, from the last sheet usage.luau installed ("" when it isn't painted).
local function rule(id: string): string
	local quoted = string.gsub(id, "%-", "%%-")
	return string.match(sheets.dots or "", "%[data%-widget='omp%-usage/" .. quoted .. "'%][^\n]*") or ""
end

-- omp missing: tern.process.run raises instead of calling back; the limits show '?', Problems says so, and the
-- next round still runs.
spawn_fails = true
usage.fetch(true)
usage.fetch_today()
local c5 = widgets["claude-5h"].render(nil)
expect(c5 and c5.text == "5h ?" and c5.tone == "error" and c5.icon == "provider-anthropic", "Claude should show '?' and its icon when omp can't start", c5 and c5.text)
expect(widgets["codex-5h"].render(nil).text == "5h ?", "Codex should show '?' when omp can't start")
expect(widgets["claude-fable"].render(nil) == nil, "Fable stays hidden when omp fails")
expect(has(widgets.health.render(nil).text, "omp ?"), "Problems shows the failed fetch")
spawn_fails = false

-- The 7d window starting right now leaves at most one weekday unlocked (20%), so 0% used is never over budget.
local v, text = render(claude(0.4, 0, now_ms + 7 * DAY))
expect(v["claude-5h"].text == "5h ●●●●● 40%" and v["claude-5h"].icon == "provider-anthropic", "Claude 5h", text)
-- 40% reaches the second of five dots: dots 1–2 green and lime, 3–5 dim, the share in lime, stops up to the end.
local r = rule("claude-5h")
expect(has(r, "#22c55e") and has(r, "#a3e635") and not has(r, "#facc15") and has(r, "100.000%"), "the dots are painted", r)
expect(has(sheets.dots, "omp-usage/claude-'] .wg-ico { color: #d97757"), "the Claude icon wears Claude's color", sheets.dots)
expect(has(v["claude-5h"].title, "resets in 1h30m"), "the tooltip has the 5h reset", v["claude-5h"].title)
expect(v["claude-5h"].command == "plugin.omp-usage.refresh", "a limit refreshes on click", v["claude-5h"].command)
expect(has(v.budget.text, "📅 left") and v.budget.tone == "ok", "budget should be 'left' at 0% weekly use", text)
expect(v["claude-fable"] == nil, "Fable must stay hidden when the plan has no Fable window", text)
expect(v.resets.text == "✦ 4" and v.resets.tone == "accent", "Claude's 1 and Codex's 2 + 1 saved resets", text)
expect(v["codex-5h"].text == "5h ●●●●● 25%" and v["codex-5h"].icon == "provider-openai-codex", "Codex 5h should be usedAccounts/accounts = 25%", text)
expect(has(v["codex-5h"].title, "2 accounts"), "Codex account count in the tooltip", v["codex-5h"].title)
expect(v.today.text == "🔥 2M" and v.cost.text == "💸 $12", "today's tokens and cost leave out yesterday's bucket", text)
expect(#v.cost.series >= 42 and v.cost.series[#v.cost.series] == 1, "the cost graph spans its width and ends at the day's total", #v.cost.series)
expect(v.speed.text == "⚡ 79 tok/s · ♻ 99%" and v.speed.value == 0.99, "speed and cache rate", v.speed and v.speed.text)
expect(v.health == nil and v.forecast == nil, "no problem and no forecast under 50%", text)

-- A rise of 3 points or more between two fetches earns the arrow; holding still drops it.
v = render(claude(0.45, 0, now_ms + 7 * DAY))
expect(v["claude-5h"].text == "5h ●●●●● 45%↑", "rising shows ↑", v["claude-5h"].text)
v = render(claude(0.45, 0, now_ms + 7 * DAY))
expect(v["claude-5h"].text == "5h ●●●●● 45%", "holding still drops ↑", v["claude-5h"].text)

-- 100% of the week with only today unlocked: over budget, and the week is locked until its reset.
v, text = render(claude(0.5, 1, now_ms + 7 * DAY, {
	{ id = "anthropic:7d:fable", amount = { usedFraction = 0.1 }, window = { resetsAt = now_ms + 7 * DAY } },
}))
expect(has(v.budget.text, "📅 over") and v.budget.tone == "error", "budget should be 'over' at 100% weekly use", text)
expect(has(v["claude-week"].text, "wk LOCKED") and v["claude-week"].tone == "error", "the lock shows at 100%", text)
expect(rule("claude-week") == "", "a locked window wears the error tone, not the dots", rule("claude-week"))
expect(v["claude-fable"] and v["claude-fable"].text == "Fable ●●●●● 10%", "Fable shows when the plan has it", text)

-- Signed in to Claude only: omp answers Codex with no reports, which hides its widgets rather than flagging an error.
v, text = render(claude(0.4, 0, now_ms + 7 * DAY), { reports = {}, capacity = {} })
expect(v["codex-5h"] == nil and v["codex-week"] == nil, "Codex should hide when omp has no Codex account", text)
expect(v.health == nil, "a provider without an account is not a problem", text)
expect(v["claude-5h"] ~= nil, "Claude stays when only Codex has no account", text)

-- Settings: each answer is what the palette prompt receives.
local function settle(answer: string, input: string): boolean
	local ok = config.answer[answer](input)
	return ok
end

expect(settle("language", "pt-br"), "language codes match case-insensitively")
v = render(claude(0, 0, now_ms + 7 * DAY))
expect(has(v.budget.text, "📅 sobra"), "pt-BR should show its own words", v.budget.text)
usage.widgets()
expect(widgets.budget.name == "Orçamento da semana útil", "registering again renames the widget for the gallery", widgets.budget.name)
settle("language", "ja")
v = render(claude(0, 0, now_ms + 7 * DAY))
expect(has(v.budget.text, "📅 残り"), "ja should show its own words", v.budget.text)
expect(not settle("language", "klingon"), "an unknown language is refused")

-- A reinstall keeps the data folder: loading the store again restores the language.
config.load()
v = render(claude(0, 0, now_ms + 7 * DAY))
expect(has(v.budget.text, "📅 残り"), "settings should survive a fresh load from tern.kv", v.budget.text)
settle("language", "en")
usage.widgets()

expect(not settle("part", "codex"), "the widget bar places the limits now, so they are not parts")
expect(not settle("part", "weather"), "an unknown part is refused")

-- Window started two days ago: three days so far; with all 7 days counting, 3/7 of the quota is unlocked.
settle("workdays", "7")
v = render(claude(0, 0, now_ms + 5 * DAY))
expect(v.budget.text == "📅 left 43%", "7 work days unlock 1/7 per day", v.budget.text)
expect(not settle("workdays", "8"), "more than 7 work days is refused")

settle("crit", "60%")
v = render(claude(0.65, 0, now_ms + 7 * DAY))
expect(has(rule("claude-5h"), "#ef4444"), "65% is critical with the threshold at 60%: the share turns red", rule("claude-5h"))
expect(not settle("crit", "20"), "a threshold under 50% is refused")

config.reset()
v = render(claude(0.65, 0, now_ms + 7 * DAY))
expect(not has(rule("claude-5h"), "#ef4444"), "reset brings the threshold back to 80%", rule("claude-5h"))
expect(store.settings ~= nil and next(store.settings) == nil, "reset leaves an empty store")

-- Alerts: climbing to the threshold, locking and freeing up each toast once; holding a level says nothing.
toasts = {}
render(claude(0.85, 0, now_ms + 7 * DAY))
expect(#toasts == 1 and toasts[1][2] == "Claude 5h at 85%", "climbing to 80% toasts once", toasts[1] and toasts[1][2])
expect(toasts[1][3] == "resets in 1h30m", "the toast says when the window resets", toasts[1][3])
render(claude(0.9, 0, now_ms + 7 * DAY))
expect(#toasts == 1, "staying above the threshold says nothing")
render(claude(1, 0, now_ms + 7 * DAY))
expect(toasts[2] and toasts[2][1] == "error" and toasts[2][2] == "Claude 5h is locked", "locking toasts an error")
render(claude(0.1, 0, now_ms + 7 * DAY))
expect(toasts[3] and toasts[3][2] == "Claude 5h is free again", "freeing up toasts")
settle("part", "alerts")
render(claude(0.85, 0, now_ms + 7 * DAY))
expect(#toasts == 3, "alerts off means no toast")
settle("part", "alerts")

-- Forecast: at 90% with the reset 90 min away (3.5 h into the 5h window), the average pace runs out in 23 min.
v = render(claude(0.9, 0, now_ms + 7 * DAY))
expect(v.forecast and v.forecast.text == "⏳ 5h 23m", "the 5h window shows when it runs out", v.forecast and v.forecast.text)
expect(has(v["claude-5h"].title, "runs out in 23m"), "and so does its tooltip", v["claude-5h"].title)
v = render(claude(0.4, 0, now_ms + 7 * DAY))
expect(v.forecast == nil, "under 50% there is no forecast")
-- Half the week gone in two days runs out in two more, before the reset five days away.
v = render(claude(0.1, 0.5, now_ms + 5 * DAY))
expect(v.forecast and v.forecast.text == "⏳ wk 2d00h", "the week shows when it runs out", v.forecast and v.forecast.text)

-- Saved resets: omp's redeemableCount says how many are usable now; one turning usable toasts, and one close to
-- expiring toasts once, across restarts.
local function credit(id: string, usable: boolean, expires_s: number): any
	return {
		id = id,
		status = "available",
		usable = usable,
		clears = { "anthropic:5h", "anthropic:7d" },
		expiresAt = os.date("!%Y-%m-%dT%H:%M:%S.000Z", expires_s),
	}
end
local no_codex = { reports = {}, capacity = {} }
local later = os.time() + 20 * 86400
toasts = {}
v = render(claude(0.1, 0, now_ms + 7 * DAY, nil, { availableCount = 2, redeemableCount = 0, credits = { credit("c1", false, later), credit("c2", false, later) } }), no_codex)
expect(v.resets.text == "✦ 0/2" and v.resets.tone == "muted", "saved but none usable yet", v.resets.text)
expect(has(v.resets.title, "clears 5h, wk") and has(v.resets.title, "usable later"), "the tooltip lists each reset", v.resets.title)
expect(#toasts == 0, "fewer usable resets say nothing", toasts[1] and toasts[1][2])
local soon = credit("c1", true, os.time() + 86400)
render(claude(0.1, 0, now_ms + 7 * DAY, nil, { availableCount = 2, redeemableCount = 1, credits = { soon, credit("c2", false, later) } }), no_codex)
expect(toasts[1] and toasts[1][2] == "Claude: 1 saved reset(s) usable now", "a reset turning usable toasts", toasts[1] and toasts[1][2])
expect(toasts[2] and has(toasts[2][2], "Claude: a saved reset expires on "), "a usable reset expiring within 2 days toasts", toasts[2] and toasts[2][2])
render(claude(0.1, 0, now_ms + 7 * DAY, nil, { availableCount = 2, redeemableCount = 1, credits = { soon, credit("c2", false, later) } }), no_codex)
expect(#toasts == 2, "each alert shows once", #toasts)
-- omp before redeemableCount: every saved reset counts as usable.
v = render(claude(0.1, 0, now_ms + 7 * DAY, nil, { availableCount = 3 }), no_codex)
expect(v.resets.text == "✦ 3", "no redeemableCount means all usable", v.resets.text)

-- A login omp turns off: Problems shows it without the account's e-mail, and it toasts once.
toasts = {}
local off = { reports = {}, capacity = {}, disabledCredentials = {
	{ provider = "openai-codex", cause = "oauth refresh failed for user@example.com: 401", email = "user@example.com" },
} }
v = render(claude(0.1, 0, now_ms + 7 * DAY), off)
expect(v.health and v.health.text == "⚠ Codex off" and v.health.tone == "error", "Problems names the login", v.health and v.health.text)
expect(has(v.health.title, "401") and not has(v.health.title, "@"), "the cause stays, the e-mail goes", v.health.title)
expect(#toasts == 1 and toasts[1][2] == "omp turned off the Codex login" and not has(toasts[1][3], "@"), "one toast for it", toasts[1] and toasts[1][2])
render(claude(0.1, 0, now_ms + 7 * DAY), off)
expect(#toasts == 1, "the same login doesn't toast again", #toasts)

-- Today's total goes to tern.kv under its local date, for the dashboard; days older than 62 are dropped.
local today_key = os.date("%Y-%m-%d") :: string
store.days = { ["2000-01-01"] = { tokens = 1, cost = 1 } }
render(claude(0.1, 0, now_ms + 7 * DAY))
expect(store.days[today_key] and store.days[today_key].cost == 12.4, "today's cost is stored for the dashboard")
expect(store.days["2000-01-01"] == nil, "days older than 62 are dropped")

print("usage_test: ok")
