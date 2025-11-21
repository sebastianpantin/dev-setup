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
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		config = true,
		opts = {
			check_ts = true,
			disable_filetype = { "TelescopePrompt", "spectre_panel" },
		},
		-- use opts = {} for passing setup options
		-- this is equalent to setup({}) function
	},
	{
		"stevearc/dressing.nvim",
		opts = {
			input = {
				enabled = false,
			},
			select = {
				-- Set to false to disable the vim.ui.select implementation
				enabled = true,

				-- Priority list of preferred vim.select implementations
				backend = { "nui", "telescope", "fzf_lua", "fzf", "builtin" },

				-- Trim trailing `:` from prompt
				trim_prompt = true,

				-- Options for nui Menu
				nui = {
					position = "50%",
					size = nil,
					relative = "editor",
					border = {
						style = "rounded",
					},
					buf_options = {
						swapfile = false,
						filetype = "DressingSelect",
					},
					win_options = {
						winblend = 10,
					},
					max_width = 80,
					max_height = 40,
					min_width = 40,
					min_height = 10,
				},

				-- Options for built-in selector
				builtin = {
					-- These are passed to nvim_open_win
					-- anchor = "NW",
					border = "rounded",
					-- 'editor' and 'win' will default to being centered
					relative = "editor",

					buf_options = {},
					win_options = {
						-- Window transparency (0-100)
						winblend = 10,
						cursorline = true,
						cursorlineopt = "both",
					},

					-- These can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
					-- the min_ and max_ options can be a list of mixed types.
					-- max_width = {140, 0.8} means "the lesser of 140 columns or 80% of total"
					width = nil,
					max_width = { 140, 0.8 },
					min_width = { 40, 0.2 },
					height = nil,
					max_height = 0.9,
					min_height = { 10, 0.2 },

					-- Set to `false` to disable
					mappings = {
						["<Esc>"] = "Close",
						["<C-c>"] = "Close",
						["<CR>"] = "Confirm",
					},
				},
			},
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
			routes = {
				{
					filter = {
						event = "msg_show",
						any = {
							{ find = "position_encoding param is required" },
							{ find = "Defaulting to position encoding" },
							{ find = "multiple different client offset_encodings" },
							{ find = "jump_to_location" },
						},
					},
					opts = { skip = true },
				},
				{
					filter = {
						event = "notify",
						any = {
							{ find = "position_encoding param is required" },
							{ find = "Defaulting to position encoding" },
							{ find = "multiple different client offset_encodings" },
							{ find = "jump_to_location" },
						},
					},
					opts = { skip = true },
				},
			},
			presets = {
				bottom_search = true, -- use a classic bottom cmdline for search
				command_palette = true, -- position the cmdline and popupmenu together
				long_message_to_split = true, -- long messages will be sent to a split
				inc_rename = false, -- enables an input dialog for inc-rename.nvim
				lsp_doc_border = false, -- add a border to hover docs and signature help
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
