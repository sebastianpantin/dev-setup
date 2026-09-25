-- Records every error-level vim.notify call and every call to a deprecated
-- Neovim API in _G.config_test_errors, and every notification (for debugging
-- failed tests) in _G.config_test_messages. Load it with `--cmd` (before
-- init.lua) so errors raised during startup count too.
--
-- Plugins like noice.nvim replace vim.notify, which would hide errors from a
-- plain wrapper. Instead, keep our wrapper permanently in front: any later
-- assignment to vim.notify only swaps the function it forwards to.

_G.config_test_errors = {}
_G.config_test_messages = {}

local notify = rawget(vim, "notify")
local function capture_notify(msg, level, opts)
	table.insert(_G.config_test_messages, tostring(msg))
	if level and level >= vim.log.levels.ERROR then
		table.insert(_G.config_test_errors, tostring(msg))
	end
	return notify(msg, level, opts)
end
rawset(vim, "notify", nil)
local mt = getmetatable(vim)
local index = mt.__index
mt.__index = function(t, k)
	if k == "notify" then
		return capture_notify
	end
	return type(index) == "function" and index(t, k) or index[k]
end
mt.__newindex = function(t, k, v)
	if k == "notify" then
		notify = v
	else
		rawset(t, k, v)
	end
end

-- Deprecated Neovim APIs only warn once per session (and via echo, not
-- vim.notify), but every call is recorded for :checkhealth vim.deprecated.
-- Hook that instead, naming the first caller outside Neovim's runtime.
local deprecated_health = require("vim.deprecated.health")
local add = deprecated_health.add
local seen = {}

-- Known deprecated calls in plugins that have no upstream fix yet. Keep this
-- list short, and remove entries once the plugin is fixed.
local allowed = {
	-- noice.nvim (latest upstream as of 2026-09) calls the old form when it
	-- renders a notification through nvim-notify. Removed in Neovim 1.0.
	{ name = "vim.str_utfindex", caller = "noice.nvim/lua/noice/view/backend/notify.lua" },
}

deprecated_health.add = function(name, version, backtrace, alternative)
	local caller = "unknown caller"
	for line in tostring(backtrace):gmatch("[^\n]+") do
		if line:find("%.lua:%d+") and not line:find(vim.env.VIMRUNTIME, 1, true) then
			caller = vim.trim(line)
			break
		end
	end
	local is_allowed = vim.iter(allowed):any(function(a)
		return a.name == name and caller:find(a.caller, 1, true) ~= nil
	end)
	local entry = ("deprecated: %s (use %s), called from %s"):format(name, alternative or "?", caller)
	if not is_allowed and not seen[entry] then
		seen[entry] = true
		table.insert(_G.config_test_errors, entry)
	end
	return add(name, version, backtrace, alternative)
end
