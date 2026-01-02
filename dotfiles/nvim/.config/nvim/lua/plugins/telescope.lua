return {
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make", lazy = true },
		},
		config = function()
			require("telescope").setup({
				defaults = {
					preview = false,
					mappings = {
						i = {
							["<C-u>"] = false,
							["<C-d>"] = false,
						},
					},
				},
			})

			pcall(require("telescope").load_extension, "fzf")

			-- Defer keymaps to speed up startup
			vim.schedule(function()
				require("core.telescope_keymaps").setup()
			end)
		end,
	},
}
