return {
	{
		"hrsh7th/nvim-cmp",
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-nvim-lua",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			require("luasnip/loaders/from_vscode").lazy_load()

			local kind_icons = {
				Array = " ",
				Boolean = " ",
				Class = " ",
				Color = " ",
				Constant = " ",
				Constructor = " ",
				Enum = " ",
				EnumMember = " ",
				Event = " ",
				Field = " ",
				File = " ",
				Folder = "󰉋 ",
				Function = " ",
				Interface = " ",
				Key = " ",
				Keyword = " ",
				Method = " ",
				Module = " ",
				Namespace = " ",
				Null = "󰟢 ",
				Number = " ",
				Object = " ",
				Operator = " ",
				Package = " ",
				Property = " ",
				Reference = " ",
				Snippet = " ",
				String = " ",
				Struct = " ",
				Text = " ",
				TypeParameter = " ",
				Unit = " ",
				Value = " ",
				Variable = " ",
			}

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-k>"] = cmp.mapping.select_prev_item(),
					["<C-j>"] = cmp.mapping.select_next_item(),
					["<C-d>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<CR>"] = cmp.mapping.confirm({
						behavior = cmp.ConfirmBehavior.Replace,
						select = false,
					}),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				formatting = {
					fields = { "kind", "abbr", "menu" },
					format = function(entry, vim_item)
						-- Kind icons
						vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
						vim_item.menu = ({
							nvim_lsp = "[LSP]",
							luasnip = "[Snippet]",
							buffer = "[Buffer]",
							path = "[Path]",
						})[entry.source.name]
						return vim_item
					end,
				},
				sources = {
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer" },
					{ name = "path" },
				},
				window = {
					completion = {
						border = require("core.constants").border_style,
						scrollbar = false,
					},
					documentation = {
						border = require("core.constants").border_style,
					},
				},
			})
		end,
	},
}
