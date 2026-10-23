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
	map("<leader>ci", function()
		require("telescope.builtin").lsp_incoming_calls()
	end, "Incoming calls")
	map("<leader>co", function()
		require("telescope.builtin").lsp_outgoing_calls()
	end, "Outgoing calls")

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
			-- The test suite installs only the tools it needs (see tests/run.sh)
			run_on_start = not vim.env.NVIM_CONFIG_TEST,
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

			-- ruff from the project's .venv so the version matches its CI; not started in
			-- projects that do not install it (see helpers.util.python_tool).
			-- Set here, not in lsp/ruff.lua, because nvim-lspconfig's lsp/ruff.lua would win.
			vim.lsp.config("ruff", {
				root_dir = function(bufnr, on_dir)
					local file_dir = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
					if require("helpers.util").python_tool(file_dir, "ruff") then
						on_dir(vim.fs.root(bufnr, { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" }) or file_dir)
					end
				end,
				cmd = function(dispatchers, config)
					local ruff = require("helpers.util").python_tool(config.root_dir, "ruff")
					return vim.lsp.rpc.start({ ruff, "server" }, dispatchers, { cwd = config.root_dir })
				end,
			})

			-- basedpyright from the project's .venv when it has one, else mason's. It reads
			-- the project's interpreter and packages, so any Python version works.
			-- Type checking is off unless the project configures it ([tool.basedpyright]
			-- or pyrightconfig.json win over these settings); mypy covers it otherwise.
			vim.lsp.config("basedpyright", {
				cmd = function(dispatchers, config)
					local server = require("helpers.util").python_tool(config.root_dir, "basedpyright-langserver")
					return vim.lsp.rpc.start(
						{ server or "basedpyright-langserver", "--stdio" },
						dispatchers,
						{ cwd = config.root_dir }
					)
				end,
				before_init = function(_, config)
					local python = config.root_dir and require("helpers.util").venv_python(config.root_dir)
					if python then
						config.settings.python = { pythonPath = python }
					end
				end,
				settings = {
					basedpyright = {
						analysis = { typeCheckingMode = "off" },
					},
				},
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
