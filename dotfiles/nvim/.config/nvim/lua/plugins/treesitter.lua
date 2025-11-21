return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = function()
			pcall(require("nvim-treesitter.install").update({ with_sync = true }))
		end,
		cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
		config = function()
			require("nvim-treesitter.configs").setup({
				sync_install = false,
				ignore_install = { "help" },
				ensure_installed = {
					"c_sharp",
					"graphql",
					"bash",
					"html",
					"javascript",
					"json",
					"lua",
					"markdown",
					"markdown_inline",
					"python",
					"query",
					"regex",
					"tsx",
					"typescript",
					"vim",
					"yaml",
					"rust",
					"ron",
					"toml",
				},

				highlight = { enable = true },
				indent = { enable = true },
			})
		end,
	},
}
