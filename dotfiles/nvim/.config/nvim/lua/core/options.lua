-- OSC 52 clipboard in tmux/SSH sessions (installed by an Omarchy migration)
require("config.remote_clipboard").setup()

local opts = {
	shiftwidth = 4,
	tabstop = 4,
	expandtab = true,
	wrap = false,
	linebreak = false,
	textwidth = 0,
	termguicolors = true,
	number = true,
	relativenumber = true,
	cmdheight = 0,
	clipboard = "unnamedplus",
	hlsearch = true,
	ignorecase = true,
	mouse = "a",
	smartcase = true,
	smartindent = true,
	splitbelow = true,
	splitright = true,
	cursorline = true,
	signcolumn = "yes",
	scrolloff = 8,
	sidescrolloff = 8,
}

-- Set options from table
for opt, val in pairs(opts) do
	vim.o[opt] = val
end

-- Set other options
local colorscheme = require("helpers.colorscheme")
vim.cmd.colorscheme(colorscheme)
