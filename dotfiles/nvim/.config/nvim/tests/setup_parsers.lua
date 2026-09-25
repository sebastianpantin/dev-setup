-- Installs every parser in the config's treesitter ensure_installed and waits
-- until all are built, so tests never trigger parser installs of their own.
-- Run by tests/run.sh during setup.

local spec = require("lazy.core.config").plugins["nvim-treesitter"]
local langs = require("lazy.core.plugin").values(spec, "opts", false).ensure_installed

-- Loading the plugin runs its setup, which starts async installs of missing parsers
require("lazy").load({ plugins = { "nvim-treesitter" } })
local install_dir = require("nvim-treesitter.configs").get_parser_install_dir()

local function missing()
	return vim.tbl_filter(function(lang)
		return vim.fn.filereadable(install_dir .. "/" .. lang .. ".so") == 0
	end, langs)
end

if not vim.wait(10 * 60 * 1000, function()
	return #missing() == 0
end, 500) then
	io.stdout:write("Treesitter parsers not installed: " .. table.concat(missing(), ", ") .. "\n")
	io.stdout:flush()
	os.exit(1)
end
os.exit(0)
