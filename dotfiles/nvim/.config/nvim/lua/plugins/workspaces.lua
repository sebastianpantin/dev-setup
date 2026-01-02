return {
	"natecraddock/workspaces.nvim",
	event = "VeryLazy",
	opts = {},
	config = function(_, opts)
		require("workspaces").setup(opts)
		require("telescope").load_extension("workspaces")
	end,
}
