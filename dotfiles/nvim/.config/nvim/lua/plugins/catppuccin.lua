return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,
		opts = {
			flavour = "mocha",
			background = {
				light = "latte",
				dark = "mocha",
			},
			dim_inactive = {
				enabled = true,
				shade = "dark",
				percentage = 0.15,
			},
			styles = {
				comments = { "italic" },
				conditionals = { "italic" },
				loops = {},
				functions = {},
				keywords = { "italic" },
				strings = {},
				variables = { "italic" },
				numbers = {},
				booleans = { "italic" },
				properties = { "italic" },
				types = {},
				operators = {},
			},
			integrations = {
				blink_cmp = true,
				gitsigns = true,
				nvimtree = true,
				telescope = true,
				treesitter = true,
				dashboard = true,
				bufferline = {
					enable = true,
					italics = true,
					bolds = true,
				},
				indent_blankline = {
					enable = true,
					colored_indent_levels = true,
				},
				fidget = true,
				noice = true,
				which_key = true,
			},
		},
	},
}
