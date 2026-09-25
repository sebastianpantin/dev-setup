-- Smoke tests for the config. Loaded with `--cmd` (before init.lua) so that
-- errors raised during startup are captured too. Run via tests/run.sh.

dofile(vim.fn.getcwd() .. "/tests/errors.lua")
local errors = _G.config_test_errors

-- Collect errors raised while running `fn`, including async ones that surface
-- shortly after (lazy.nvim reports plugin config errors via vim.notify).
local function capture(fn)
	local before = #errors
	vim.v.errmsg = ""
	local ok, err = pcall(fn)
	vim.wait(50)
	local found = vim.list_slice(errors, before + 1)
	if not ok then
		table.insert(found, tostring(err))
	end
	if vim.v.errmsg ~= "" then
		table.insert(found, vim.v.errmsg)
	end
	return found
end

local results = { passed = 0, failed = {} }

local function test(name, fn)
	local ok, err = pcall(fn)
	if ok then
		results.passed = results.passed + 1
		io.stdout:write("  ok    " .. name .. "\n")
	else
		table.insert(results.failed, name)
		io.stdout:write("  FAIL  " .. name .. "\n        " .. tostring(err):gsub("\n", "\n        ") .. "\n")
	end
end

local function eq(actual, expected, what)
	if not vim.deep_equal(actual, expected) then
		error(("%s: expected %s, got %s"):format(what, vim.inspect(expected), vim.inspect(actual)), 2)
	end
end

local function no_errors(found, what)
	if #found > 0 then
		error(what .. ":\n" .. table.concat(found, "\n"), 2)
	end
end

local function run()
	local startup_errors = vim.list_extend({}, errors)
	if vim.v.errmsg ~= "" then
		table.insert(startup_errors, vim.v.errmsg)
	end

	local lazy = require("lazy")
	local plugins = lazy.plugins()

	test("startup has no errors", function()
		no_errors(startup_errors, "errors during startup")
	end)

	test("all plugins are installed", function()
		local missing = {}
		for _, p in ipairs(plugins) do
			if not p._.installed then
				table.insert(missing, p.name)
			end
		end
		eq(missing, {}, "missing plugins")
	end)

	test("lockfile covers every plugin", function()
		local lock = vim.json.decode(table.concat(vim.fn.readfile(vim.fn.stdpath("config") .. "/lazy-lock.json"), "\n"))
		local unlocked = {}
		for _, p in ipairs(plugins) do
			if not lock[p.name] then
				table.insert(unlocked, p.name)
			end
		end
		eq(unlocked, {}, "plugins missing from lazy-lock.json")
	end)

	test("VeryLazy plugins load without errors", function()
		no_errors(capture(function()
			vim.api.nvim_exec_autocmds("User", { pattern = "VeryLazy", modeline = false })
		end), "VeryLazy")
	end)

	for _, p in ipairs(plugins) do
		test("plugin loads: " .. p.name, function()
			no_errors(capture(function()
				lazy.load({ plugins = { p.name } })
			end), p.name)
			assert(p._.loaded, "not marked as loaded")
		end)
	end

	test("opening files triggers no errors", function()
		local cfg = vim.fn.stdpath("config")
		for _, file in ipairs({ cfg .. "/init.lua", cfg .. "/lazy-lock.json" }) do
			no_errors(capture(function()
				vim.cmd.edit(vim.fn.fnameescape(file))
			end), file)
		end
	end)

	test("treesitter highlighting is active for lua", function()
		vim.cmd.edit(vim.fn.fnameescape(vim.fn.stdpath("config") .. "/init.lua"))
		eq(vim.bo.filetype, "lua", "filetype")
		assert(vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()], "no treesitter highlighter attached")
		eq(vim.bo.indentexpr, "v:lua.require'nvim-treesitter'.indentexpr()", "indentexpr")
	end)

	test("configured treesitter parsers are available", function()
		local langs = require("core.constants").treesitter_parsers
		local missing = {}
		for _, lang in ipairs(langs) do
			-- language.add returns (nil, err) on failure rather than raising
			local ok, added = pcall(vim.treesitter.language.add, lang)
			if not (ok and added) then
				table.insert(missing, lang)
			end
		end
		eq(missing, {}, "missing parsers")
	end)

	test("colorscheme is catppuccin", function()
		eq(vim.g.colors_name, "catppuccin-mocha", "colors_name")
	end)

	test("core options are set", function()
		eq(vim.g.mapleader, " ", "mapleader")
		eq(vim.o.expandtab, true, "expandtab")
		eq(vim.o.shiftwidth, 4, "shiftwidth")
		eq(vim.o.relativenumber, true, "relativenumber")
		eq(vim.o.clipboard, "unnamedplus", "clipboard")
		eq(vim.o.signcolumn, "yes", "signcolumn")
	end)

	test("keymaps are defined", function()
		vim.wait(50) -- telescope keymaps are set in vim.schedule
		local missing = {}
		for _, lhs in ipairs({
			"<leader>cd", "]d", "[d", "]e", "[e", "]w", "[w",
			"<S-l>", "<S-h>", "<leader>bd",
			"<C-h>", "<C-j>", "<C-k>", "<C-l>",
			"<leader>L", "<leader>M", "<leader>e",
			"<leader>ff", "<leader>fr", "<leader>fp", "<leader>sg", "<leader>sw", "<leader>sh", "<leader>sd", "<C-p>",
			"<leader>gb", "<leader>gba", "<leader>v",
		}) do
			if vim.fn.maparg(lhs, "n") == "" then
				table.insert(missing, lhs)
			end
		end
		eq(missing, {}, "missing normal-mode keymaps")
	end)

	test("user commands exist", function()
		local missing = {}
		for _, cmd in ipairs({
			"Lazy", "Mason", "Telescope", "Neotree", "BufDel", "ConformInfo", "Gitsigns", "Dooing", "Noice", "TSInstall",
		}) do
			if vim.fn.exists(":" .. cmd) ~= 2 then
				table.insert(missing, cmd)
			end
		end
		eq(missing, {}, "missing commands")
	end)

	test("LSP servers have a config and are enabled", function()
		local bad = {}
		for _, name in ipairs(require("core.constants").lsp_servers) do
			local cfg = vim.lsp.config[name]
			if not (cfg and cfg.cmd) then
				table.insert(bad, name .. " (no config/cmd)")
			elseif not vim.lsp.is_enabled(name) then
				table.insert(bad, name .. " (not enabled)")
			end
		end
		eq(bad, {}, "LSP problems")
	end)

	test("lsp/*.lua override files return tables", function()
		for _, file in ipairs(vim.api.nvim_get_runtime_file("lsp/*.lua", true)) do
			if vim.startswith(file, vim.fn.stdpath("config")) then
				eq(type(dofile(file)), "table", file)
			end
		end
	end)

	test("formatters are configured", function()
		local conform = require("conform")
		eq(conform.formatters_by_ft.lua, { "stylua" }, "lua formatter")
		eq(conform.formatters_by_ft.typescript, { "prettierd" }, "typescript formatter")
	end)

	test("no errors were reported during the test run", function()
		no_errors(errors, "errors")
	end)

	local failed = #results.failed
	io.stdout:write(("\n%d passed, %d failed\n"):format(results.passed, failed))
	-- :qall! can hang on plugin jobs (e.g. mason installs), so exit directly.
	io.stdout:flush()
	os.exit(failed > 0 and 1 or 0)
end

vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		vim.schedule(function()
			local ok, err = pcall(run)
			if not ok then
				io.stdout:write("test runner crashed: " .. tostring(err) .. "\n")
				io.stdout:flush()
				os.exit(2)
			end
		end)
	end,
})
