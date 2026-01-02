local M = {}

-- Setup all Telescope keymaps
-- Keeping these separate makes them easier to modify without touching plugin config
M.setup = function()
	local map = require("helpers.keys").map
	local builtin = require("telescope.builtin")

	map("n", "<leader>fr", builtin.oldfiles, "Recently opened")
	map("n", "<leader>ff", builtin.find_files, "Files")
	map("n", "<leader>fp", ":Telescope workspaces <CR>", "Workspaces")
	map("n", "<leader>sh", builtin.help_tags, "Help")
	map("n", "<leader>sw", builtin.grep_string, "Current word")
	map("n", "<leader>sg", builtin.live_grep, "Grep")
	map("n", "<leader>sd", builtin.diagnostics, "Diagnostics")
	map("n", "<C-p>", builtin.keymaps, "Search keymaps")
end

return M
