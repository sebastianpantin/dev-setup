return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false, -- the main branch does not support lazy-loading
		build = ":TSUpdate",
		config = function()
			-- Async, and a no-op for parsers that are already installed
			require("nvim-treesitter").install(require("core.constants").treesitter_parsers)

			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					-- Fails for filetypes without an installed parser
					if not pcall(vim.treesitter.start, args.buf) then
						return
					end
					local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
					if lang and vim.treesitter.query.get(lang, "indents") then
						vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end,
			})
		end,
	},
}
