return {
	"stevearc/aerial.nvim",
	opts = {},
	-- Optional dependencies
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		local map = require("helpers.keys").map
		require("aerial").setup({
			on_attach = function()
				map("n", "<leader>a", "<cmd>AerialToggle!<CR>", "Toggle aerial")
				vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>")
			end,
		})
	end,
}
