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

T["remote clipboard is used inside tmux"] = function()
	-- Restart with TMUX set; the child inherits this process's environment
	local tmux = vim.env.TMUX
	vim.env.TMUX = "/tmp/tmux-test,1,0"
	local ok, err = pcall(child.start_config)
	vim.env.TMUX = tmux
	assert(ok, err)
	MiniTest.expect.equality(child.lua_get("vim.g.clipboard and vim.g.clipboard.name"), "OmarchyRemoteClipboard")
end

return T
