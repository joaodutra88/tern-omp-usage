-- Claude + Codex limits from `omp usage --json` (gradient dots, trend, lockout) and today's tokens from `omp stats`.
local M = {}

local P = "plugin.omp-usage."
local DOTS = 5
local TREND_STEP = 0.03 -- rise between two fetches (5 min) that earns the arrow
local DAILY = 0.20 -- weekly quota split over Mon–Fri

-- Every word the bar shows; translate here.
M.labels = { left = "left", over = "over", locked = "LOCKED", tokens = "tokens" }

local OMP: string = "omp"
local busy = false
local failed = { claude = false, codex = false }
local claude: { [string]: any }? = nil
local codex: { [string]: any }? = nil
local prev: { [string]: number } = {}
local rising: { [string]: boolean } = {}
local today: { tokens: number, cost: number }? = nil
local anim = DOTS

local function num(x: any): number?
	return if type(x) == "number" then x else nil
end

local function mins_until(ms: number?): number?
	return if ms then math.max(0, math.floor((ms / 1000 - os.time()) / 60)) else nil
end

local function hm(mins: number): string
	if mins >= 1440 then
		return string.format("%dd%02dh", mins // 1440, (mins % 1440) // 60)
	end
	return if mins >= 60 then string.format("%dh%02dm", mins // 60, mins % 60) else string.format("%dm", mins)
end

local function track(key: string, f: number?)
	if not f then
		return
	end
	rising[key] = prev[key] ~= nil and f - prev[key] >= TREND_STEP
	prev[key] = f
end

-- Weekdays of the 7d window up to today each unlock DAILY; a holiday's share stays banked.
local function weekly_slack(used: number?, resets: number?): number?
	if not used or not resets then
		return nil
	end
	local start = resets / 1000 - 7 * 86400
	local today_key = os.date("%Y%m%d") :: string
	local days = 0
	for i = 0, 7 do
		local at = start + i * 86400
		if (os.date("%Y%m%d", at) :: string) > today_key then
			break
		end
		local wday = (os.date("*t", at) :: any).wday
		if wday >= 2 and wday <= 6 then
			days += 1
		end
	end
	return math.min(1, days * DAILY) - used
end

local function slack_segment(out: { any }, used: number?, resets: number?)
	local s = weekly_slack(used, resets)
	if not s then
		return
	end
	local pct = math.floor(math.abs(s) * 100 + 0.5)
	if s >= 0 then
		table.insert(out, { text = string.format("📅 %s %d%%", M.labels.left, pct), command = P .. "slack-ok" })
	else
		table.insert(out, { text = string.format("📅 %s %d%%", M.labels.over, pct), command = P .. "slack-bad" })
	end
end

-- Five steps green → red; dot N always wears step N, the percentage wears the step it reached.
local function bar(out: { any }, label: string, f: number?, key: string)
	table.insert(out, { text = label, tone = "muted", command = P .. "refresh" })
	if not f then
		table.insert(out, { text = "–", tone = "muted", command = P .. "refresh" })
		return
	end
	local filled = math.min(math.clamp(math.floor(f * DOTS + 0.5), 0, DOTS), anim)
	for i = 1, filled do
		table.insert(out, { text = "●", command = P .. "dot-" .. i })
	end
	if filled < DOTS then
		table.insert(out, { text = string.rep("●", DOTS - filled), command = P .. "empty" })
	end
	local pct = string.format("%d%%", math.floor(f * 100 + 0.5)) .. (if rising[key] then "↑" else "")
	local step = math.clamp(math.ceil(f * DOTS), 1, DOTS)
	table.insert(out, { text = pct, command = P .. (if f >= 0.8 then "pct-crit" else "pct-" .. step) })
end

local function parse_claude(data): { [string]: any }?
	local report = data.reports and data.reports[1]
	if not report then
		return nil
	end
	local c = {}
	for _, l in report.limits do
		local key = if l.id == "anthropic:5h" then "five" elseif l.id == "anthropic:7d" then "week"
			elseif l.id == "anthropic:7d:fable" then "fable" else nil
		if key then
			c[key] = num(l.amount.usedFraction)
			c[key .. "_reset"] = num(l.window.resetsAt)
		end
	end
	c.credits = if type(report.resetCredits) == "table" then num(report.resetCredits.availableCount) or 0 else 0
	return c
end

local function parse_codex(data): { [string]: any }?
	local reports = data.reports
	if not reports or #reports == 0 then
		return nil
	end
	local x = { credits = 0 }
	for _, cap in (data.capacity and data.capacity["openai-codex"]) or {} do
		local frac = if cap.accounts and cap.accounts > 0 then cap.usedAccounts / cap.accounts else nil
		if cap.window == "5h" then
			x.five = frac
		elseif cap.window == "7d" then
			x.week = frac
		end
		x.n = cap.accounts
	end
	for _, r in reports do
		for _, l in r.limits do
			local key = if l.id == "openai-codex:primary" then "five_reset" elseif l.id == "openai-codex:secondary" then "week_reset" else nil
			local at = key and num(l.window.resetsAt)
			if key and at and (not x[key] or at < x[key]) then
				x[key] = at
			end
		end
		if type(r.resetCredits) == "table" then
			x.credits += num(r.resetCredits.availableCount) or 0
		end
	end
	return x
end

-- Dots fill left to right after each fetch.
local function animate()
	anim = 0
	local function step()
		anim += 1
		tern.chrome.refresh()
		if anim < DOTS then
			tern.timer(90, step)
		end
	end
	tern.timer(90, step)
end

local function run_json(argv: { string }, done: (any?) -> ())
	tern.process.run(argv, { timeout_ms = 60000 }, function(res)
		local ok, data = pcall(tern.json.decode, res.stdout)
		done(if res.status == 0 and ok then data else nil)
	end)
end

function M.fetch(invalidate: boolean?)
	if busy then
		return
	end
	busy = true
	tern.chrome.refresh()
	local pending = 2
	local function finish()
		pending -= 1
		if pending == 0 then
			busy = false
			animate()
		end
	end
	local function go()
		run_json({ OMP, "usage", "--json", "-p", "anthropic" }, function(data)
			local c = data and parse_claude(data)
			failed.claude = c == nil
			if c then
				claude = c
				track("c5", c.five)
				track("cwk", c.week)
			end
			finish()
		end)
		run_json({ OMP, "usage", "--json", "-p", "openai-codex" }, function(data)
			local x = data and parse_codex(data)
			failed.codex = x == nil
			if x then
				codex = x
				track("x5", x.five)
				track("xwk", x.week)
			end
			finish()
		end)
	end
	if invalidate then
		tern.process.run({ OMP, "usage", "invalidate" }, { timeout_ms = 30000 }, go)
	else
		go()
	end
end

local function midnight_ms(): number
	local t = os.date("*t") :: any
	return os.time({ year = t.year, month = t.month, day = t.day, hour = 0, min = 0, sec = 0 }) * 1000
end

-- Tokens and API-price cost since local midnight, every provider, from `omp stats` hourly buckets.
function M.fetch_today()
	run_json({ OMP, "stats", "--json" }, function(data)
		if not data or not data.timeSeries then
			return
		end
		local since = midnight_ms()
		local tokens, cost = 0, 0
		for _, b in data.timeSeries do
			if (num(b.timestamp) or 0) >= since then
				tokens += num(b.tokens) or 0
				cost += num(b.cost) or 0
			end
		end
		today = { tokens = tokens, cost = cost }
		tern.chrome.refresh()
	end)
end

local function compact(n: number): string
	return if n >= 1e9 then string.format("%.1fB", n / 1e9) elseif n >= 1e6 then string.format("%.0fM", n / 1e6)
		elseif n >= 1e3 then string.format("%.0fk", n / 1e3) else tostring(n)
end

local function locked(out: { any }, name: string, five: number?, week: number?, r5: number?, rwk: number?, tail: string?)
	if (five or 0) < 1 and (week or 0) < 1 then
		return
	end
	local mins = mins_until(if (week or 0) >= 1 then rwk else r5)
	table.insert(out, {
		text = string.format("%s %s %s%s", name, M.labels.locked, if mins then hm(mins) else "", tail or ""),
		command = P .. "locked",
	})
end

function M.segments(out: { any })
	local c = claude
	if c then
		locked(out, "CLAUDE", c.five, c.week, c.five_reset, c.week_reset, if c.credits > 0 then " ✦" .. c.credits else nil)
		table.insert(out, { text = "✻ Claude", command = P .. "claude" })
		bar(out, "5h", c.five, "c5")
		bar(out, "wk", c.week, "cwk")
		if c.fable then
			bar(out, "Fable", c.fable, "cf")
		end
		local mins = mins_until(c.five_reset)
		if mins then
			local soon = (c.five or 0) >= 0.8 and mins < 30
			table.insert(out, { text = "reset " .. hm(mins), command = if soon then P .. "reset-soon" else P .. "reset" })
		end
		if c.credits > 0 then
			table.insert(out, { text = "✦" .. c.credits, command = P .. "credits" })
		end
		slack_segment(out, c.week, c.week_reset)
	elseif failed.claude then
		table.insert(out, { text = "✻ Claude ?", tone = "error", command = P .. "refresh" })
	end

	local x = codex
	if x then
		locked(out, "CODEX", x.five, x.week, x.five_reset, x.week_reset, if x.credits > 0 then " ✦" .. x.credits else nil)
		table.insert(out, { text = "⬢ Codex", command = P .. "codex" })
		bar(out, "5h", x.five, "x5")
		bar(out, "wk", x.week, "xwk")
		if x.n then
			table.insert(out, { text = "×" .. x.n, tone = "muted", command = P .. "refresh" })
		end
		if x.credits > 0 then
			table.insert(out, { text = "✦" .. x.credits, command = P .. "credits" })
		end
	elseif failed.codex then
		table.insert(out, { text = "⬢ Codex ?", tone = "error", command = P .. "refresh" })
	end

	if today then
		table.insert(out, { text = "🔥 " .. compact(today.tokens) .. " " .. M.labels.tokens, command = P .. "today" })
		table.insert(out, { text = string.format("💸 $%.0f", today.cost), command = P .. "cost" })
	end
	if failed.claude or failed.codex then
		table.insert(out, { text = "⚠", tone = "error", command = P .. "refresh" })
	end
	table.insert(out, if busy then { text = "⟳ …", tone = "muted" } else { text = "⟳", tone = "accent", command = P .. "refresh" })
end

function M.init(omp: string, hidden: (string, (any) -> ()) -> ())
	OMP = omp
	for _, id in { "claude", "codex", "credits", "today", "cost", "dot-1", "dot-2", "dot-3", "dot-4", "dot-5",
		"pct-1", "pct-2", "pct-3", "pct-4", "pct-5", "pct-crit", "empty", "locked", "reset", "reset-soon", "slack-ok", "slack-bad" } do
		hidden(id, function()
			M.fetch(true)
		end)
	end
end

return M
