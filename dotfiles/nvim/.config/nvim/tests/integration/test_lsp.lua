-- Uses lua_ls and stylua, installed into the test environment by tests/run.sh.
local H = dofile(vim.fn.getcwd() .. "/tests/integration/helpers.lua")
local expect, eq = MiniTest.expect, MiniTest.expect.equality

local LSP_TIMEOUT = 30000
local main_file = H.fixture("lua_project/main.lua")

local child = H.new_child()
local T = H.new_set(child)

-- Open `file` and wait until lua_ls has attached to it.
local function open_with_lsp(file)
	child.cmd("edit " .. vim.fn.fnameescape(file))
	H.wait_for(child, "#vim.lsp.get_clients({ bufnr = 0, name = 'lua_ls' }) > 0", LSP_TIMEOUT)
end

T["lua_ls attaches and sets LSP keymaps"] = function()
	open_with_lsp(main_file)
	for _, lhs in ipairs({ "gd", "gr", "K", "<Space>cr", "<Space>ca", "<Space>cf" }) do
		expect.no_equality(child.fn.maparg(lhs, "n"), "")
	end
end

T["lua_ls reports diagnostics"] = function()
	open_with_lsp(main_file)
	H.wait_for(child, "#vim.diagnostic.get(0) > 0", LSP_TIMEOUT)
	local messages = child.lua_get("vim.tbl_map(function(d) return d.message end, vim.diagnostic.get(0))")
	expect.equality(vim.iter(messages):any(function(m)
		return m:find("undefined_global_function", 1, true) ~= nil
	end), true)
end

T["hover returns documentation"] = function()
	open_with_lsp(main_file)
	child.api.nvim_win_set_cursor(0, { 5, 0 }) -- on the `greet("world")` call
	-- lua_ls answers with empty hovers until it has loaded the workspace, so poll
	child.lua([[
		_G.hover_text = function()
			local params = vim.lsp.util.make_position_params(0, "utf-16")
			for _, res in pairs(vim.lsp.buf_request_sync(0, "textDocument/hover", params, 5000) or {}) do
				if res.result then
					return res.result.contents.value
				end
			end
			return ""
		end
	]])
	H.wait_for(child, "_G.hover_text():find('function greet', 1, true) ~= nil", LSP_TIMEOUT)
end

T["gd jumps to the definition"] = function()
	open_with_lsp(main_file)
	child.api.nvim_win_set_cursor(0, { 5, 0 })
	child.type_keys("gd")
	H.wait_for(child, "vim.api.nvim_win_get_cursor(0)[1] == 1", LSP_TIMEOUT)
end

T["<leader>cf formats with stylua"] = function()
	open_with_lsp(main_file)
	child.set_lines({ "local   t = {1,2,3}" }) -- only the buffer changes, the file isn't saved
	child.type_keys("<Space>cf")
	H.wait_for(child, "vim.api.nvim_buf_get_lines(0, 0, -1, false)[1] == 'local t = { 1, 2, 3 }'")
	eq(child.lines(), { "local t = { 1, 2, 3 }" })
end

return T
