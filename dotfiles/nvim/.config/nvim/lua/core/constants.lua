local M = {}

-- LSP servers to install and configure
M.lsp_servers = {
	"lua_ls",
	"pylsp",
	"ruff",
	"csharp_ls",
	"dockerls",
	"terraformls",
	"yamlls",
	"fsautocomplete",
	"vtsls",
	"eslint",
}

-- File types to exclude from certain features
M.excluded_filetypes = {
	"help",
	"startify",
	"dashboard",
	"lazy",
	"neogitstatus",
	"NvimTree",
	"NeoTree",
	"Trouble",
	"text",
	"mason",
	"harpoon",
	"DressingInput",
	"DressingSelect",
	"NeogitCommitMessage",
	"NeogitStatus",
	"qf",
	"dirvish",
	"oil",
	"minifiles",
	"fugitive",
	"alpha",
	"netrw",
	"lir",
	"DiffviewFiles",
	"Outline",
	"Jaq",
	"spectre_panel",
	"toggleterm",
	"TelescopePrompt",
}

-- Buffer types to exclude
M.excluded_buftypes = {
	"terminal",
	"nofile",
}

-- Common border style
M.border_style = "rounded"

-- Diagnostic signs
M.diagnostic_signs = {
	text = {
		[vim.diagnostic.severity.ERROR] = " ",
		[vim.diagnostic.severity.WARN] = " ",
		[vim.diagnostic.severity.HINT] = " ",
		[vim.diagnostic.severity.INFO] = " ",
	},
}

return M
