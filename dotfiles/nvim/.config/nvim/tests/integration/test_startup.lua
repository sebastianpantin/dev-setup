local H = dofile(vim.fn.getcwd() .. "/tests/integration/helpers.lua")
local child = H.new_child()
local T = H.new_set(child)

T["dashboard is shown on startup"] = function()
	H.wait_for(child, "vim.bo.filetype == 'dashboard'")
	-- The footer shows startup time, which differs on every run
	H.expect_screenshot(child, "dashboard", { ignore_pattern = "Neovim loaded" })
end

T["dashboard keys open their pickers"] = function()
	H.wait_for(child, "vim.bo.filetype == 'dashboard'")
	child.type_keys("f")
	H.wait_for(child, "vim.bo.filetype == 'TelescopePrompt'")
end

-- Environment variables that make lua/config/remote_clipboard.lua kick in
local remote_env = { "TMUX", "SSH_TTY", "SSH_CONNECTION", "HERDR_PANE_ID" }

-- Restart with only `name` (if any) of remote_env set; the child inherits this
-- process's environment, which may itself be inside tmux or SSH.
local function start_with_remote_env(name)
	local saved = {}
	for _, var in ipairs(remote_env) do
		saved[var] = vim.env[var]
		vim.env[var] = var == name and "test" or nil
	end
	local ok, err = pcall(child.start_config)
	for _, var in ipairs(remote_env) do
		vim.env[var] = saved[var]
	end
	assert(ok, err)
end

local function clipboard_name()
	return child.lua_get("type(vim.g.clipboard) == 'table' and vim.g.clipboard.name or ''")
end

-- The config also enables it under a herdr ancestor process (checking up to
-- 16 levels), which the child shares with this one: the test runner's
-- ancestors are the child's too.
local function under_herdr()
	local pid = vim.fn.getpid()
	for _ = 1, 16 do
		if not pid or pid <= 1 then
			break
		end
		local comm = vim.fn.readfile("/proc/" .. pid .. "/comm")[1] or ""
		if comm:find("herdr", 1, true) then
			return true
		end
		local status = table.concat(vim.fn.readfile("/proc/" .. pid .. "/status"), "\n")
		pid = tonumber(status:match("PPid:%s+(%d+)"))
	end
	return false
end

for _, var in ipairs(remote_env) do
	T["remote clipboard is used with $" .. var] = function()
		if under_herdr() then
			MiniTest.skip("herdr enables the remote clipboard regardless; covered by tests/docker.sh")
		end
		start_with_remote_env(var)
		MiniTest.expect.equality(clipboard_name(), "OmarchyRemoteClipboard")
	end
end

T["remote clipboard is not used locally"] = function()
	start_with_remote_env(nil)
	MiniTest.expect.equality(clipboard_name() == "OmarchyRemoteClipboard", under_herdr())
end

return T
