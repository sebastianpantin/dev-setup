-- Follow the Omarchy theme.
--
-- Each Omarchy theme ships a neovim.lua written for LazyVim: plugin specs for its
-- colorscheme plus a "LazyVim/LazyVim" spec whose opts.colorscheme names it. This
-- config isn't LazyVim, so the colorscheme is read out of the current theme's
-- file, and every stock theme's colorscheme plugin is installed lazily so
-- switching themes in a running Neovim doesn't need a restart.
--
-- Paths are read on each call, so tests can point them elsewhere.
local M = {}

local FALLBACK = "catppuccin-mocha"
local LAZYVIM = "LazyVim/LazyVim"

-- Omarchy keeps the current theme in ~/.local/state. Honouring XDG_STATE_HOME
-- also keeps the test suite, which redirects it, off the real theme.
local function current_dir()
	return vim.fs.joinpath(vim.env.XDG_STATE_HOME or vim.fn.expand("~/.local/state"), "omarchy", "current")
end

local function current_file()
	return vim.fs.joinpath(current_dir(), "theme", "neovim.lua")
end

local function load_spec(path)
	local chunk = loadfile(path)
	if not chunk then
		return {}
	end
	local ok, spec = pcall(chunk)
	return ok and type(spec) == "table" and spec or {}
end

--- The colorscheme the current Omarchy theme sets, or catppuccin-mocha outside Omarchy.
function M.colorscheme()
	for _, spec in ipairs(load_spec(current_file())) do
		if spec[1] == LAZYVIM and type(spec.opts) == "table" and spec.opts.colorscheme then
			return spec.opts.colorscheme
		end
	end
	return FALLBACK
end

--- lazy.nvim specs for the colorscheme plugins of every stock theme and of the
--- current one, which may be the user's own. lazy.nvim loads a lazy plugin when
--- :colorscheme names one of its colorschemes. Only the source is kept: a
--- theme's opts (e.g. catppuccin's flavour) would override the ones in
--- lua/plugins, and the colorscheme name already picks the variant.
function M.plugins()
	local files = vim.fn.glob(vim.fs.joinpath(vim.env.OMARCHY_PATH or "/usr/share/omarchy", "themes/*/neovim.lua"), true, true)
	table.insert(files, current_file())
	local plugins = {}
	for _, file in ipairs(files) do
		for _, spec in ipairs(load_spec(file)) do
			if type(spec[1]) == "string" and spec[1] ~= LAZYVIM then
				table.insert(plugins, { spec[1], name = spec.name, dependencies = spec.dependencies, lazy = true })
			end
		end
	end
	return plugins
end

--- Switch to the current theme's colorscheme if it changed.
function M.apply()
	local name = M.colorscheme()
	if name ~= vim.g.colors_name and not pcall(vim.cmd.colorscheme, name) then
		vim.notify(("Colorscheme %s isn't installed; restart Neovim to install it"):format(name), vim.log.levels.WARN)
	end
end

--- Apply the colorscheme, and re-apply it whenever Omarchy switches theme.
function M.setup()
	M.apply()
	local dir = current_dir()
	if vim.fn.isdirectory(dir) == 0 then
		return
	end
	local watcher = vim.uv.new_fs_event()
	local timer = vim.uv.new_timer()
	-- theme-set rewrites several files; act once it has settled.
	watcher:start(dir, {}, function()
		timer:start(200, 0, vim.schedule_wrap(M.apply))
	end)
end

return M
