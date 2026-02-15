local constants = require("core.constants")

return {
	{
		"RRethy/vim-illuminate",
		event = "VeryLazy",
		opts = {
			delay = 200,
			large_file_cutoff = 2000,
			large_file_overrides = {
				providers = { "lsp" },
			},
			filetypes_denylist = constants.excluded_filetypes,
		},
		config = function(_, opts)
			require("illuminate").configure(opts)
		end,
	},
	{
		"NvChad/nvim-colorizer.lua",
		event = "BufReadPost",
		config = function()
			local colorizer_status_ok, colorizer = pcall(require, "colorizer")
			if not colorizer_status_ok then
				print("colorizer not found!")
			end
			colorizer.setup({
				user_default_options = {
					css = true,
				},
			})
		end,
		lazy = true,
	},
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
		opts = {
			check_ts = true,
			disable_filetype = { "TelescopePrompt", "spectre_panel" },
		},
	},
	-- Move stuff with <M-j> and <M-k> in both normal and visual mode
	{
		"echasnovski/mini.move",
		config = function()
			require("mini.move").setup()
		end,
	},
	{
		"nmac427/guess-indent.nvim",
		opts = {
			auto_cmd = true,
		},
	},
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		opts = {
			lsp = {
				progress = {
					enabled = false,
				},
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},
			presets = {
				bottom_search = true,
				command_palette = true,
				long_message_to_split = true,
				inc_rename = false,
				lsp_doc_border = false,
			},
		},
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = "VeryLazy",
		opts = {
			exclude = {
				filetypes = constants.excluded_filetypes,
				buftypes = constants.excluded_buftypes,
			},
			indent = {
				char = "│",
				tab_char = "│",
			},
			scope = {
				show_start = true,
				show_end = true,
			},
			whitespace = { remove_blankline_trail = true },
		},
	},
}
