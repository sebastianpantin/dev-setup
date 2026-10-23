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
				-- Only called when python_tool found a mypy (see the autocmd below)
				cmd = function()
					return require("helpers.util").python_tool(vim.fn.expand("%:p:h"), "mypy")
				end,
				-- Check against the project's .venv packages, not mason's own environment
				args = vim.list_extend(vim.deepcopy(lint.linters.mypy.args), {
					function()
						local python = require("helpers.util").venv_python(vim.fn.expand("%:p:h"))
						return "--python-executable=" .. (python or vim.fn.exepath("python3"))
					end,
				}),
			})
			vim.api.nvim_create_autocmd({ "BufWritePost" }, {
				callback = function()
					-- Skip mypy in projects that do not install it
					if vim.bo.filetype == "python" and not require("helpers.util").python_tool(vim.fn.expand("%:p:h"), "mypy") then
						return
					end
					lint.try_lint()
				end,
			})
		end,
	},
}
