local H = dofile(vim.fn.getcwd() .. "/tests/integration/helpers.lua")
local eq = MiniTest.expect.equality

local child = H.new_child()
local T = H.new_set(child)

-- prettierd isn't installed in the test environment. Put a stub on the
-- child's PATH so that conform only skips it when its `condition` fails.
local function stub_prettierd()
	local bin = vim.fn.tempname()
	vim.fn.mkdir(bin, "p")
	vim.fn.writefile({ "#!/bin/sh" }, bin .. "/prettierd")
	vim.fn.setfperm(bin .. "/prettierd", "rwxr-xr-x")
	child.lua("vim.env.PATH = ... .. ':' .. vim.env.PATH", { bin })
end

-- Open `file` and return the names of the formatters <leader>cf would run.
local function formatters_to_run(file)
	child.cmd("edit " .. vim.fn.fnameescape(file))
	-- conform picks formatters by filetype, so make sure there is one
	eq(child.bo.filetype, file:match("%.ts$") and "typescript" or "javascript")
	return child.lua_get([[vim.tbl_map(function(f)
		return f.name
	end, (require("conform").list_formatters_to_run(0)))]])
end

T["prettierd"] = MiniTest.new_set({ parametrize = { { "index.ts" }, { "index.js" } } })

T["prettierd"]["runs under a directory with a .prettierrc"] = function(file)
	stub_prettierd()
	eq(formatters_to_run(H.fixture("prettier_project/src/" .. file)), { "prettierd" })
end

T["prettierd"]["is skipped without a prettier config"] = function(file)
	stub_prettierd()
	local dir = vim.fn.tempname()
	vim.fn.mkdir(dir, "p")
	-- Copy the file rather than open a new one: in the child (though not in a
	-- real session), the first new file opened after startup gets no filetype
	vim.fn.writefile(vim.fn.readfile(H.fixture("prettier_project/src/" .. file)), dir .. "/" .. file)
	eq(formatters_to_run(dir .. "/" .. file), {})
end

return T
