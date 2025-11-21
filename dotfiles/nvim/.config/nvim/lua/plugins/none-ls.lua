return {
	{
		"jay-babu/mason-null-ls.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			"nvimtools/none-ls.nvim",
		},
		config = function()
			require("mason-null-ls").setup({
				ensure_installed = { "stylua", "prettierd", "mypy", "fantomas", "yamlfix" },
				automatic_installation = true,
			})
		end,
	},
	{
		"nvimtools/none-ls.nvim",
		dependencies = {
			"nvimtools/none-ls-extras.nvim",
		},
		opts = function()
			local nls = require("null-ls")
			local formatting = nls.builtins.formatting -- to setup formatters
			local diagnostics = nls.builtins.diagnostics -- to setup linters
			return {
				sources = {
					formatting.prettierd.with({
						condition = function(utils)
							return utils.root_has_file(".prettierrc")
						end,
					}),
					formatting.fantomas,
					formatting.yamlfix,
					formatting.stylua,
					diagnostics.mypy.with({ prefer_local = ".venv/bin" }),
				},
				debug = true,
			}
		end,
	},
}
