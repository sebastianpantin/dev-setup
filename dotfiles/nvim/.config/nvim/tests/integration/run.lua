-- Entry point for the integration suite (see tests/run.sh --integration).
-- Any error outside a test case (e.g. a syntax error in a test file) must exit
-- non-zero; otherwise headless Neovim waits at the error prompt forever.
local ok, err = pcall(function()
	require("mini.test").setup()
	MiniTest.run({
		collect = {
			find_files = function()
				return vim.fn.globpath("tests/integration", "test_*.lua", true, true)
			end,
		},
	})
end)
if not ok then
	io.stdout:write("Integration suite crashed: " .. tostring(err) .. "\n")
	io.stdout:flush()
	os.exit(2)
end
