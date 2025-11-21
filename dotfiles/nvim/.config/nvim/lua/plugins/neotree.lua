-- Nicer filetree than NetRW
return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		config = function()
			require("neo-tree").setup({
				sources = { "filesystem", "buffers", "git_status" },
				open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
				filesystem = {
					bind_to_cwd = true,
					follow_current_file = { enabled = true },
					use_libuv_file_watcher = true,
				},
				default_component_configs = {
					indent = {
						with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
						expander_collapsed = "",
						expander_expanded = "",
						expander_highlight = "NeoTreeExpander",
					},
					git_status = {
						symbols = {
							unstaged = "󰄱",
							staged = "󰱒",
						},
					},
				},
			})
			require("helpers.keys").map({ "n", "v" }, "<leader>e", "<cmd>Neotree toggle<cr>", "Toggle file explorer")
		end,
	},
}
