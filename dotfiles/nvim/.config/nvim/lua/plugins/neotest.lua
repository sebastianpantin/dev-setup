return {
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"nvim-neotest/neotest-python",
		},
		keys = {
			{
				"<leader>tn",
				function()
					require("neotest").run.run()
				end,
				desc = "Test nearest",
			},
			{
				"<leader>tf",
				function()
					require("neotest").run.run(vim.fn.expand("%"))
				end,
				desc = "Test file",
			},
			{
				"<leader>ta",
				function()
					-- pytest ignores its testpaths when given a directory, so pass tests/ when there is one
					local tests = vim.fs.joinpath(vim.uv.cwd(), "tests")
					require("neotest").run.run(vim.fn.isdirectory(tests) == 1 and tests or vim.uv.cwd())
				end,
				desc = "Test all",
			},
			{
				"<leader>td",
				function()
					require("neotest").run.run({ strategy = "dap" })
				end,
				desc = "Debug nearest test",
			},
			{
				"<leader>tl",
				function()
					require("neotest").run.run_last()
				end,
				desc = "Test last",
			},
			{
				"<leader>to",
				function()
					require("neotest").output.open({ enter = true })
				end,
				desc = "Test output",
			},
			{
				"<leader>tO",
				function()
					require("neotest").output_panel.toggle()
				end,
				desc = "Test output panel",
			},
			{
				"<leader>ts",
				function()
					require("neotest").summary.toggle()
				end,
				desc = "Test summary",
			},
		},
		config = function()
			require("neotest").setup({
				status = { virtual_text = true },
				adapters = {
					require("neotest-python")({
						runner = "pytest",
						-- The project's .venv, so pytest sees its packages
						python = function()
							return require("helpers.util").venv_python(vim.uv.cwd()) or "python3"
						end,
					}),
				},
			})
		end,
	},
}
