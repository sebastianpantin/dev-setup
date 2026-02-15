local constants = require("core.constants")

local function on_lsp_attach(args)
	local client = vim.lsp.get_client_by_id(args.data.client_id)
	if not client then
		return
	end

	local function map(lhs, rhs, desc)
		vim.keymap.set("n", lhs, rhs, { silent = true, buffer = args.buf, desc = desc })
	end

	map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
	map("<leader>ca", vim.lsp.buf.code_action, "Code action")
	map("<leader>cy", vim.lsp.buf.type_definition, "Type definition")
	map("<leader>ls", function()
		require("telescope.builtin").lsp_document_symbols()
	end, "Document symbols")

	map("gd", function()
		require("telescope.builtin").lsp_definitions()
	end, "Goto Definition")
	map("gr", function()
		require("telescope.builtin").lsp_references()
	end, "Goto References")
	map("gI", vim.lsp.buf.implementation, "Goto Implementation")
	map("K", vim.lsp.buf.hover, "Hover Documentation")
	map("gD", vim.lsp.buf.declaration, "Goto Declaration")

	map("<leader>cf", function()
		require("conform").format({ lsp_format = "fallback" })
	end, "Format")

	-- Server-specific overrides
	if client.name == "vtsls" then
		client.server_capabilities.documentFormattingProvider = false
	end
	if client.name == "ruff" then
		client.server_capabilities.hoverProvider = false
	end

	-- Inlay hints
	if client:supports_method("textDocument/inlayHint") then
		vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
	end

	-- Illuminate
	require("illuminate").on_attach(client)
end

return {
	{
		"williamboman/mason.nvim",
		lazy = false,
		opts = {},
		keys = {
			{ "<leader>M", "<cmd>Mason<cr>", desc = "Mason" },
		},
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim" },
		lazy = false,
		opts = {
			ensure_installed = constants.mason_packages,
		},
	},
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			"RRethy/vim-illuminate",
		},
		config = function()
			-- Diagnostic config
			vim.diagnostic.config({
				virtual_text = {
					spacing = 4,
					prefix = "●",
					severity = { min = vim.diagnostic.severity.WARN },
				},
				signs = constants.diagnostic_signs,
				update_in_insert = false,
				underline = true,
				severity_sort = true,
				float = {
					focusable = true,
					style = "minimal",
					border = constants.border_style,
					source = true,
					header = "",
					prefix = "",
				},
			})

			-- LspAttach keymaps and config
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = on_lsp_attach,
			})

			-- Shared capabilities (blink.cmp)
			vim.lsp.config("*", {
				capabilities = require("blink.cmp").get_lsp_capabilities(),
			})

			-- Enable all configured LSP servers
			vim.lsp.enable(constants.lsp_servers)
		end,
	},
	{
		"yioneko/nvim-vtsls",
		ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	},
}
