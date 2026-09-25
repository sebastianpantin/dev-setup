local H = dofile(vim.fn.getcwd() .. "/tests/integration/helpers.lua")
local expect, eq = MiniTest.expect, MiniTest.expect.equality

local child = H.new_child()
local T = H.new_set(child, { files = { H.config_dir .. "/init.lua", H.config_dir .. "/lazy-lock.json" } })

local function any_window_with_filetype(ft)
	return ([[vim.iter(vim.api.nvim_list_wins()):any(function(w)
		return vim.bo[vim.api.nvim_win_get_buf(w)].filetype == %q
	end)]]):format(ft)
end

T["<leader>ff opens Telescope file finder"] = function()
	child.type_keys("<Space>ff")
	H.wait_for(child, "vim.bo.filetype == 'TelescopePrompt'")
end

T["<C-p> opens Telescope keymap search"] = function()
	child.type_keys("<C-p>")
	H.wait_for(child, "vim.bo.filetype == 'TelescopePrompt'")
end

T["<leader>e toggles Neo-tree"] = function()
	child.type_keys("<Space>e")
	H.wait_for(child, any_window_with_filetype("neo-tree"))
	child.type_keys("<Space>e")
	H.wait_for(child, "not " .. any_window_with_filetype("neo-tree"))
end

T["<S-l>/<S-h> cycle buffers"] = function()
	eq(child.fn.expand("%:t"), "init.lua")
	child.type_keys("<S-l>")
	eq(child.fn.expand("%:t"), "lazy-lock.json")
	child.type_keys("<S-h>")
	eq(child.fn.expand("%:t"), "init.lua")
end

T["<leader>bd deletes the buffer"] = function()
	eq(#child.fn.getbufinfo({ buflisted = 1 }), 2)
	child.type_keys("<Space>bd")
	eq(#child.fn.getbufinfo({ buflisted = 1 }), 1)
end

T["<C-h>/<C-l> move between splits"] = function()
	child.type_keys("<Space>v") -- which-key mapping for :vsplit
	-- Count splits only: notifications are floating windows
	eq(child.lua_get([[#vim.tbl_filter(function(w)
		return vim.api.nvim_win_get_config(w).relative == ""
	end, vim.api.nvim_tabpage_list_wins(0))]]), 2)
	local right = child.api.nvim_get_current_win()
	child.type_keys("<C-h>")
	expect.no_equality(child.api.nvim_get_current_win(), right)
	child.type_keys("<C-l>")
	eq(child.api.nvim_get_current_win(), right)
end

T["]d/]e jump to diagnostics"] = function()
	child.lua([[
		local ns = vim.api.nvim_create_namespace("test")
		vim.diagnostic.set(ns, 0, {
			{ lnum = 2, col = 0, message = "warning", severity = vim.diagnostic.severity.WARN },
			{ lnum = 5, col = 0, message = "error", severity = vim.diagnostic.severity.ERROR },
		})
	]])
	child.api.nvim_win_set_cursor(0, { 1, 0 })
	child.type_keys("]d")
	eq(child.api.nvim_win_get_cursor(0)[1], 3)
	child.api.nvim_win_set_cursor(0, { 1, 0 })
	child.type_keys("]e")
	eq(child.api.nvim_win_get_cursor(0)[1], 6)
end

return T
