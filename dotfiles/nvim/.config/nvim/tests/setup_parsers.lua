-- Installs every parser in core.constants.treesitter_parsers and waits until
-- all are built, so tests never trigger parser installs of their own.
-- Run by tests/run.sh during setup.

local parsers = require("core.constants").treesitter_parsers

-- The config already started installing these; install() waits on those too
local ok, err = pcall(function()
	require("nvim-treesitter").install(parsers):wait(10 * 60 * 1000)
end)

local installed = require("nvim-treesitter.config").get_installed("parsers")
local missing = vim.tbl_filter(function(lang)
	return not vim.list_contains(installed, lang)
end, parsers)

if not ok or #missing > 0 then
	io.stdout:write(("Treesitter parsers not installed: %s\n%s\n"):format(table.concat(missing, ", "), err or ""))
	io.stdout:flush()
	os.exit(1)
end
os.exit(0)
