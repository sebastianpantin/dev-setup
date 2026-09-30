-- Installs every parser in core.constants.treesitter_parsers and waits until
-- all are built, so tests never trigger parser installs of their own.
-- Run by tests/run.sh during setup.

local parsers = require("core.constants").treesitter_parsers
local config = require("nvim-treesitter.config")

-- nvim-treesitter counts a language as installed once either its parser or
-- its queries are in place, so an install cut short between the two (see
-- tests/run.sh) is never finished by a plain install().
local function incomplete()
	local built, queries = config.get_installed("parsers"), config.get_installed("queries")
	return vim.tbl_filter(function(lang)
		return not (vim.list_contains(built, lang) and vim.list_contains(queries, lang))
	end, parsers)
end

-- The config already started installing these; install() waits on those too
local ok, err = pcall(function()
	require("nvim-treesitter").install(parsers):wait(10 * 60 * 1000)
	local broken = incomplete()
	if #broken > 0 then
		require("nvim-treesitter").install(broken, { force = true }):wait(10 * 60 * 1000)
	end
end)

local missing = incomplete()
if not ok or #missing > 0 then
	io.stdout:write(("Treesitter parsers not installed: %s\n%s\n"):format(table.concat(missing, ", "), err or ""))
	io.stdout:flush()
	os.exit(1)
end
os.exit(0)
