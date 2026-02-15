return {
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				javascript = { "prettierd" },
				javascriptreact = { "prettierd" },
				typescript = { "prettierd" },
				typescriptreact = { "prettierd" },
				css = { "prettierd" },
				html = { "prettierd" },
				json = { "prettierd" },
				markdown = { "prettierd" },
				fsharp = { "fantomas" },
				yaml = { "yamlfix" },
			},
			formatters = {
				prettierd = {
					condition = function(self, ctx)
						return vim.fs.find(function(name)
							return name:match("^%.prettierrc") or name:match("^prettier%.config%.")
						end, { path = ctx.dirname, upward = true })[1] ~= nil
					end,
				},
			},
		},
	},
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local lint = require("lint")
			lint.linters_by_ft = {
				python = { "mypy" },
			}
			lint.linters.mypy = vim.tbl_deep_extend("force", lint.linters.mypy or {}, {
				cmd = function()
					local venv = vim.fn.findfile(".venv/bin/mypy", vim.fn.getcwd() .. ";")
					if venv ~= "" then
						return venv
					end
					return "mypy"
				end,
			})
			vim.api.nvim_create_autocmd({ "BufWritePost" }, {
				callback = function()
					lint.try_lint()
				end,
			})
		end,
	},
}
