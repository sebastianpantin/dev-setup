-- Records every error-level vim.notify call in _G.config_test_errors, and every
-- notification (for debugging failed tests) in _G.config_test_messages. Load it
-- with `--cmd` (before init.lua) so errors raised during startup count too.
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
