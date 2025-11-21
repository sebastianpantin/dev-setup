return {
	"nvimdev/dashboard-nvim",
	event = "VimEnter",
	config = function()
		local logo = [[
	███    ██ ███████  ██████  ██    ██ ██ ███    ███
	████   ██ ██      ██    ██ ██    ██ ██ ████  ████
	██ ██  ██ █████   ██    ██ ██    ██ ██ ██ ████ ██
	██  ██ ██ ██      ██    ██  ██  ██  ██ ██  ██  ██
	██   ████ ███████  ██████    ████   ██ ██      ██

    ]]
		logo = string.rep("\n", 8) .. logo .. "\n"
		require("dashboard").setup({
			theme = "doom",
			hide = {
				statusline = false,
			},
			config = {
				header = vim.split(logo, "\n"),
				-- stylua: ignore
				center = {
					{
						action = function()
							vim.cmd("Telescope workspaces")
						end,
						desc = " Workspaces",
						icon = " ",
						key = "p"
					},
					{ action = require("telescope.builtin").find_files, desc = " Find File", icon = " ", key = "f" },
					{ action = "ene | startinsert", desc = " New File", icon = " ", key = "n" },
					{ action = require("telescope.builtin").oldfiles, desc = " Recent Files", icon = " ", key = "r" },
					{ action = require("telescope.builtin").live_grep, desc = " Find Text", icon = " ", key = "g" },
					{ action = ":e ~/.config/nvim/init.lua", desc = "Config", icon = "  ", key = "c" },
					{ action = "Lazy", desc = " Lazy", icon = "󰒲 ", key = "l" },
					{ action = function() vim.api.nvim_input("<cmd>qa<cr>") end, desc = " Quit", icon = " ", key = "q" },
				},
				footer = function()
					local stats = require("lazy").stats()
					local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
					return { "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
				end,
			},
		})
	end,
	dependencies = { { "nvim-tree/nvim-web-devicons" } },
}
