-- Dashboard data: hourly usage series from `omp usage --history --json` and cost totals from the days the
-- window half records in tern.kv. No tern calls, so tests/history_test.luau runs it directly.
local M = {}

-- The limits the status line shows, in its order.
M.LIMITS = {
	{ id = "anthropic:5h", name = "Claude", window = "5h" },
	{ id = "anthropic:7d", name = "Claude", window = "wk" },
	{ id = "openai-codex:primary", name = "Codex", window = "5h" },
	{ id = "openai-codex:secondary", name = "Codex", window = "wk" },
}

-- Per limit id, `{ hour start (epoch s), used fraction }` oldest first. Accounts of one limit in the same hour
-- are averaged. Only limitId, usedFraction and recordedAt are read: entries also carry emails and account ids.
function M.series(entries: { any }): { [string]: { { number } } }
	local sums: { [string]: { [number]: { number } } } = {}
	for _, e in entries do
		local f, at = e.usedFraction, e.recordedAt
		if type(e.limitId) == "string" and type(f) == "number" and type(at) == "number" then
			local hour = at // 3600000
			local by_hour = sums[e.limitId] or {}
			sums[e.limitId] = by_hour
			local s = by_hour[hour] or { 0, 0 }
			by_hour[hour] = s
			s[1] += f
			s[2] += 1
		end
	end
	local out: { [string]: { { number } } } = {}
	for id, by_hour in sums do
		local hours: { number } = {}
		for h in by_hour do
			table.insert(hours, h)
		end
		table.sort(hours)
		local points: { { number } } = {}
		for _, h in hours do
			table.insert(points, { h * 3600, by_hour[h][1] / by_hour[h][2] })
		end
		out[id] = points
	end
	return out
end

local function cost_of(d: any): number
	return if type(d) == "table" and type(d.cost) == "number" then d.cost else 0
end

-- Cost today, over the last 7 days (today included) and this calendar month, plus the last 7 days oldest first
-- as `{ "MM-DD", cost }`. `days` maps "YYYY-MM-DD" (local) to `{ tokens, cost }`.
function M.costs(days: { [string]: any }, now: number): { today: number, week: number, month: number, last7: { { any } } }
	local month = os.date("%Y-%m", now) :: string
	local r = { today = 0, week = 0, month = 0, last7 = {} }
	for key, d in days do
		if string.sub(key, 1, 7) == month then
			r.month += cost_of(d)
		end
	end
	for i = 6, 0, -1 do
		local t = now - i * 86400
		local cost = cost_of(days[os.date("%Y-%m-%d", t) :: string])
		r.week += cost
		table.insert(r.last7, { os.date("%m-%d", t), cost })
		if i == 0 then
			r.today = cost
		end
	end
	return r
end

return M
