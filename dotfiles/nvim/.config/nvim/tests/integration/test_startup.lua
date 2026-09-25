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

return T
