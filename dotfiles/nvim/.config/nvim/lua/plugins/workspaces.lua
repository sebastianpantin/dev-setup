return {
	"natecraddock/workspaces.nvim",
	opts = {},
	config = function(_, opts)
		require("workspaces").setup(opts)
		require("telescope").load_extension("workspaces")
	end,
}
