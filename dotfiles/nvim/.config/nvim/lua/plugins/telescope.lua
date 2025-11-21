return {
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make", lazy = true },
		},
		config = function()
			require("telescope").load_extension("aerial")
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
				extensions = {
					aerial = {
						show_nesting = {
							["_"] = false,
							json = true,
							yaml = true,
						},
					},
				},
			})

			pcall(require("telescope").load_extension, "fzf")

			-- Load keymaps from separate module for easier maintenance
			require("core.telescope_keymaps").setup()
		end,
	},
}
