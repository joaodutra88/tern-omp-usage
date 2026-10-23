-- Host half: the dashboard block. 7 days of Claude and Codex usage from `omp usage --history`, and the API-price
-- cost of today, the last 7 days and this month. Opened by OMP usage: dashboard or a click on today's cost.
local config = require("./config")
local history = require("./history")
local ui = tern.ui
local OMP = config.omp_bin()

type State = {
	cx: BlockCx,
	series: { [string]: { { number } } }?,
	days: { [string]: any },
	failed: boolean,
	loading: boolean,
	fetched: number?,
}

-- A pane id survives Restart, so the state object identifies this run of the block.
local running: { [number]: State } = {}

-- Blocks have no close hook; a process answering after the pane closed must not render it.
local function alive(state: State): boolean
	if running[state.cx.pane] ~= state then
		return false
	end
	for _, p in tern.pane.list() do
		if p.pane == state.cx.pane then
			return true
		end
	end
	running[state.cx.pane] = nil
	return false
end

local function load(state: State)
	if state.loading then
		return
	end
	state.loading = true
	config.load()
	local ok, days = pcall(tern.kv.get, "days")
	state.days = if ok and type(days) == "table" then days else {}
	local argv = { OMP, "usage", "--history", "--json", "--days", "7" }
	local started = pcall(tern.process.run, argv, { timeout_ms = 60000 }, function(res)
		if not alive(state) then
			return
		end
		state.loading = false
		local decoded, data = pcall(tern.json.decode, res.stdout)
		state.failed = not (res.status == 0 and decoded and type(data) == "table" and type(data.entries) == "table")
		if not state.failed then
			state.series = history.series(data.entries)
			state.fetched = os.time()
		end
		state.cx:render()
	end)
	if not started then
		state.loading = false
		state.failed = true
	end
end

local function pct(f: number): string
	return string.format("%d%%", math.floor(f * 100 + 0.5))
end

local function usage_cards(series: { [string]: { { number } } }): { Node }
	local cards: { Node } = {}
	for _, name in { "Claude", "Codex" } do
		local rows: { Node } = {}
		for _, limit in history.LIMITS do
			local points = series[limit.id]
			if limit.name == name and points and #points > 0 then
				local now = points[#points][2]
				local spark: { { any } } = {}
				for _, p in points do
					table.insert(spark, { os.date("%m-%d %Hh", p[1]), math.floor(p[2] * 100 + 0.5) })
				end
				table.insert(rows, ui.meter(math.clamp(now, 0, 1), limit.window .. " " .. pct(now)))
				table.insert(rows, ui.spark(spark))
			end
		end
		if #rows > 0 then
			table.insert(cards, ui.card(name, rows))
		end
	end
	return cards
end

local function cost_card(days: { [string]: any }): Node
	local L = config.labels
	if next(days) == nil then
		return ui.card(L.dash_cost, { ui.text(ui.span(L.dash_cost_empty, "muted")) })
	end
	local c = history.costs(days, os.time())
	local function money(n: number): string
		return string.format("$%.0f", n)
	end
	return ui.card(L.dash_cost, {
		ui.kv({ { L.dash_today, money(c.today) }, { L.dash_week, money(c.week) }, { L.dash_month, money(c.month) } }),
		ui.bars(c.last7),
	})
end

tern.block.define("dashboard", {
	init = function(cx: BlockCx, _args: { string }, _saved: any): State
		local state: State = { cx = cx, series = nil, days = {}, failed = false, loading = false, fetched = nil }
		running[cx.pane] = state
		load(state)
		return state
	end,

	title = function(_state: State): string?
		return "OMP usage"
	end,

	view = function(state: State, _cx: BlockCx): BlockView
		local L = config.labels
		local parts: { Node } = {}
		if state.series then
			for _, card in usage_cards(state.series) do
				table.insert(parts, card)
			end
			if #parts == 0 then
				table.insert(parts, ui.text(ui.span(L.dash_no_history, "muted")))
			end
		elseif state.failed then
			table.insert(parts, ui.text(ui.span(L.dash_failed, "warning")))
		else
			table.insert(parts, ui.progress(nil, L.dash_loading))
		end
		table.insert(parts, cost_card(state.days))
		local status: { Span | string } = {}
		if state.fetched then
			table.insert(status, ui.span(string.format(L.dash_updated, os.date("%H:%M", state.fetched)), "muted"))
		end
		table.insert(status, ui.span("  r " .. L.dash_refresh, "dim"))
		return { main = ui.col(parts), dock = ui.col({ ui.text(status) }) }
	end,

	key = function(state: State, key: Key, _cx: BlockCx): boolean?
		if key.ctrl or key.alt or key.meta or (key.text or key.name) ~= "r" then
			return false
		end
		load(state)
		return true
	end,
})
