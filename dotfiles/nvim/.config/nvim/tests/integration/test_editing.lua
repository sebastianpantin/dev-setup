local H = dofile(vim.fn.getcwd() .. "/tests/integration/helpers.lua")
local eq = MiniTest.expect.equality

local child = H.new_child()
local T = H.new_set(child)

-- Scratch Lua buffer with `lines`, cursor on the last line.
local function lua_buffer(lines)
	child.cmd("enew")
	child.bo.filetype = "lua"
	child.set_lines(lines)
	child.api.nvim_win_set_cursor(0, { #lines, 0 })
end

T["autopairs closes brackets"] = function()
	lua_buffer({ "" })
	child.type_keys("i", "print(")
	eq(child.lines(), { "print()" })
end

T["blink.cmp completes from the buffer"] = function()
	lua_buffer({ "local completion_candidate = 1", "" })
	-- blink.cmp is lazy-loaded on InsertEnter; give it a moment, then type at
	-- human speed (keys sent in one burst are processed before it listens)
	child.type_keys("i")
	vim.wait(200)
	child.type_keys(20, vim.split("completion_c", ""))
	H.wait_for(child, "require('blink.cmp').is_menu_visible()", 5000)
	-- Nothing is preselected: <C-j> picks the first item, <CR> accepts it
	child.type_keys("<C-j>", "<CR>")
	eq(child.lines()[2], "completion_candidate")
end

T["<M-j>/<M-k> move lines (mini.move)"] = function()
	lua_buffer({ "local a = 1", "local b = 2" })
	child.api.nvim_win_set_cursor(0, { 1, 0 })
	child.type_keys("<M-j>")
	eq(child.lines(), { "local b = 2", "local a = 1" })
	child.type_keys("<M-k>")
	eq(child.lines(), { "local a = 1", "local b = 2" })
end

T["vim-illuminate highlights the word under the cursor"] = function()
	lua_buffer({ "local value = 1", "print(value)" })
	child.api.nvim_win_set_cursor(0, { 2, 7 }) -- on `value`
	-- Both occurrences of `value` get a highlight extmark
	H.wait_for(child, [[#vim.api.nvim_buf_get_extmarks(0, vim.api.nvim_create_namespace("illuminate.highlight"), 0, -1, {}) == 2]], 3000)
end

T["gcc toggles a comment"] = function()
	lua_buffer({ "local x = 1" })
	child.type_keys("gcc")
	eq(child.lines(), { "-- local x = 1" })
	child.type_keys("gcc")
	eq(child.lines(), { "local x = 1" })
end

return T
