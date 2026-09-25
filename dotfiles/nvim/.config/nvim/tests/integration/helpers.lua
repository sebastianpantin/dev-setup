-- Shared helpers for the mini.test integration suite. Run via
-- `tests/run.sh --integration`, which sets up the isolated environment.
local H = {}

local expect = MiniTest.expect

H.config_dir = vim.fn.getcwd()

H.fixture = function(path)
	return H.config_dir .. "/tests/fixtures/" .. path
end

-- Poll `expr` (a Lua expression evaluated in the child) until it is truthy.
-- On timeout, the error includes the child's most recent notifications.
H.wait_for = function(child, expr, timeout)
	timeout = timeout or 5000
	local ok = vim.wait(timeout, function()
		-- The child can be briefly blocked (e.g. mid-keystroke); just retry.
		local called, value = pcall(child.lua_get, expr)
		return called and value
	end, 20)
	if not ok then
		local _, messages = pcall(child.lua_get, "_G.config_test_messages")
		local recent = type(messages) == "table" and vim.list_slice(messages, #messages - 4) or {}
		error(("timed out after %dms waiting for: %s\nRecent notifications:\n%s"):format(
			timeout,
			expr,
			#recent > 0 and table.concat(recent, "\n") or "(none)"
		), 2)
	end
end

-- A child Neovim running the real config, with extra helpers attached.
H.new_child = function()
	local child = MiniTest.new_child_neovim()

	-- Start (or restart) with the config, optionally opening `files`.
	child.start_config = function(files)
		local args = {
			-- mini.test always passes --clean, which drops the config dir from 'rtp'
			"--cmd", "set rtp^=" .. vim.fn.fnameescape(H.config_dir),
			"--cmd", "luafile " .. vim.fn.fnameescape(H.config_dir .. "/tests/errors.lua"),
			"-u", H.config_dir .. "/init.lua",
		}
		child.restart(vim.list_extend(args, files or {}))
		-- Headless children never get UIEnter, which is what fires lazy.nvim's
		-- VeryLazy event; send it the way a real terminal would.
		child.api.nvim_exec_autocmds("UIEnter", {})
		H.wait_for(child, "vim.g.did_very_lazy == true")
	end

	child.expect_no_errors = function()
		expect.equality(child.lua_get("_G.config_test_errors"), {})
		expect.equality(child.v.errmsg, "")
	end

	child.lines = function()
		return child.api.nvim_buf_get_lines(0, 0, -1, false)
	end

	child.set_lines = function(lines)
		child.api.nvim_buf_set_lines(0, 0, -1, false, lines)
	end

	return child
end

-- Standard set: fresh config per case, fail the case on any reported error.
H.new_set = function(child, opts)
	opts = opts or {}
	return MiniTest.new_set({
		hooks = {
			pre_case = function()
				child.start_config(opts.files)
			end,
			post_case = child.expect_no_errors,
			post_once = child.stop,
		},
	})
end

-- Compare against a reference screenshot in tests/screenshots/<name>.
-- Screen rows containing `opts.ignore_pattern` (plain text) are skipped, for
-- content that changes between runs.
-- A missing reference is created on the first local run (commit it); in CI a
-- missing reference is an error, so a forgotten file can't pass silently.
H.expect_screenshot = function(child, name, opts)
	opts = opts or {}
	local path = vim.env.NVIM_TEST_SCREENSHOTS .. "/" .. name
	if vim.env.CI and vim.fn.filereadable(path) == 0 then
		error("missing reference screenshot " .. path .. " (run tests/run.sh --integration locally and commit it)")
	end
	local screenshot = child.get_screenshot()
	local ignore = {}
	if opts.ignore_pattern then
		for row, chars in ipairs(screenshot.text) do
			if table.concat(chars):find(opts.ignore_pattern, 1, true) then
				table.insert(ignore, row)
			end
		end
	end
	expect.reference_screenshot(screenshot, path, { ignore_text = ignore, ignore_attr = ignore })
end

return H
