-- Runs history.luau (the dashboard's data) on canned `omp usage --history` entries and recorded days.
-- Run: luau tests/history_test.luau (from the repository root, or via scripts/check.py).
local history = require("../history")

local function expect(ok: boolean, what: string, got: any)
	if not ok then
		error(what .. " (got: " .. tostring(got) .. ")", 2)
	end
end

local HOUR = 3600000
local t0 = 1792000000 // 3600 * HOUR -- an hour start

-- Two Codex accounts in the same hour are averaged; a later hour comes after it; other providers and fields
-- without a number are left out.
local s = history.series({
	{ limitId = "openai-codex:primary", usedFraction = 0.2, recordedAt = t0 + 5000, email = "user@example.com" },
	{ limitId = "openai-codex:primary", usedFraction = 0.6, recordedAt = t0 + 9000 },
	{ limitId = "anthropic:5h", usedFraction = 0.9, recordedAt = t0 + HOUR },
	{ limitId = "anthropic:5h", usedFraction = 0.3, recordedAt = t0 },
	{ limitId = "anthropic:7d", usedFraction = "x", recordedAt = t0 },
})
expect(#s["openai-codex:primary"] == 1, "two accounts in one hour make one point", #s["openai-codex:primary"])
expect(math.abs(s["openai-codex:primary"][1][2] - 0.4) < 1e-9, "accounts in one hour are averaged", s["openai-codex:primary"][1][2])
expect(s["anthropic:5h"][1][2] == 0.3 and s["anthropic:5h"][2][2] == 0.9, "points are oldest first", s["anthropic:5h"][1][2])
expect(s["anthropic:5h"][1][1] == t0 // 1000, "a point starts at its hour, in seconds", s["anthropic:5h"][1][1])
expect(s["anthropic:7d"] == nil, "a fraction that is not a number is skipped", s["anthropic:7d"])

-- Costs: noon on the 10th, so the last 7 days run from the 4th; the month counts days 1 to 10 only.
local now = os.time({ year = 2026, month = 10, day = 10, hour = 12 })
local c = history.costs({
	["2026-10-10"] = { tokens = 1, cost = 5 },
	["2026-10-04"] = { tokens = 1, cost = 2 },
	["2026-10-03"] = { tokens = 1, cost = 7 },
	["2026-09-30"] = { tokens = 1, cost = 100 },
	["2026-10-02"] = "broken",
}, now)
expect(c.today == 5, "today is the entry for the local date", c.today)
expect(c.week == 7, "the last 7 days include today and stop at the 4th", c.week)
expect(c.month == 14, "the month leaves September out", c.month)
expect(#c.last7 == 7 and c.last7[1][1] == "10-04" and c.last7[7][1] == "10-10", "bars run oldest first", c.last7[1][1])
expect(c.last7[2][2] == 0, "a day without an entry costs 0", c.last7[2][2])

print("history_test: ok")
