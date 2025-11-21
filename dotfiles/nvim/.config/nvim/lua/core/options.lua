local opts = {
	shiftwidth = 4,
	tabstop = 4,
	expandtab = true,
	wrap = false,
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
	scrolloff = 0,
	sidescrolloff = 8,
}

-- Set options from table
for opt, val in pairs(opts) do
	vim.o[opt] = val
end

-- Set other options
local colorscheme = require("helpers.colorscheme")
vim.cmd.colorscheme(colorscheme)
