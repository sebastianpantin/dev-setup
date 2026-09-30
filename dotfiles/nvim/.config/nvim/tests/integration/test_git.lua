local H = dofile(vim.fn.getcwd() .. "/tests/integration/helpers.lua")
local expect, eq = MiniTest.expect, MiniTest.expect.equality

local child = H.new_child()
local T = H.new_set(child)

-- Keep the host's git config (hooks, excludes, diff settings) out of the tests
local git_env = { GIT_CONFIG_GLOBAL = "/dev/null", GIT_CONFIG_NOSYSTEM = "1" }

-- A throwaway repo with one committed file, whose second line is then changed.
-- Returns the file's path.
local function repo_with_change()
	local dir = vim.fn.tempname()
	vim.fn.mkdir(dir, "p")
	local function git(...)
		local res = vim.system({ "git", "-C", dir, ... }, { text = true, env = git_env }):wait()
		assert(res.code == 0, res.stderr)
	end
	git("init", "--quiet")
	-- There is no global git identity to fall back on
	git("config", "user.name", "Test User")
	git("config", "user.email", "test@example.com")
	local file = dir .. "/file.txt"
	vim.fn.writefile({ "one", "two", "three" }, file)
	git("add", "file.txt")
	git("commit", "--quiet", "-m", "Initial commit")
	vim.fn.writefile({ "one", "changed", "three" }, file)
	return file
end

-- Open `file` and wait until gitsigns has computed its hunks.
local function open_in_gitsigns(file)
	-- gitsigns runs git from the child, so isolate it there too
	child.lua("for name, value in pairs(...) do vim.env[name] = value end", { git_env })
	child.cmd("edit " .. vim.fn.fnameescape(file))
	H.wait_for(child, "#(require('gitsigns').get_hunks(0) or {}) > 0")
end

T["gitsigns marks the changed line"] = function()
	open_in_gitsigns(repo_with_change())
	local hunks = child.lua_get([[vim.tbl_map(function(h)
		return { type = h.type, start = h.added.start, count = h.added.count }
	end, require("gitsigns").get_hunks(0))]])
	eq(hunks, { { type = "change", start = 2, count = 1 } })
	-- ...with a sign on that line only (0-based rows)
	local sign_rows = [[vim.tbl_map(function(m)
		return m[2]
	end, vim.api.nvim_buf_get_extmarks(0, -1, 0, -1, { type = "sign" }))]]
	H.wait_for(child, "#" .. sign_rows .. " > 0")
	eq(child.lua_get(sign_rows), { 1 })
end

T["<leader>gb shows blame for the line"] = function()
	open_in_gitsigns(repo_with_change())
	child.api.nvim_win_set_cursor(0, { 1, 0 }) -- an unchanged, committed line
	child.lua([[
		_G.blame_text = function()
			for _, w in ipairs(vim.api.nvim_list_wins()) do
				if vim.w[w].gitsigns_preview == "blame" then
					return table.concat(vim.api.nvim_buf_get_lines(vim.api.nvim_win_get_buf(w), 0, -1, false), "\n")
				end
			end
			return ""
		end
	]])
	child.type_keys("<Space>gb")
	H.wait_for(child, "_G.blame_text():find('Initial commit', 1, true) ~= nil")
	expect.no_equality(child.lua_get("_G.blame_text()"):find("Test User", 1, true), nil)
end

return T
