local map = require("helpers.keys").map

-- Diagnostics
local diagnostic_jump = function(count, severity)
	severity = severity and vim.diagnostic.severity[severity] or nil
	return function()
		vim.diagnostic.jump({ count = count, severity = severity })
	end
end
map("n", "<leader>cd", vim.diagnostic.open_float, "Line Diagnostics")
map("n", "]d", diagnostic_jump(1), "Next Diagnostic")
map("n", "[d", diagnostic_jump(-1), "Prev Diagnostic")
map("n", "]e", diagnostic_jump(1, "ERROR"), "Next Error")
map("n", "[e", diagnostic_jump(-1, "ERROR"), "Prev Error")
map("n", "]w", diagnostic_jump(1, "WARN"), "Next Warning")
map("n", "[w", diagnostic_jump(-1, "WARN"), "Prev Warning")

-- Navigate buffers
map("n", "<S-l>", ":bnext<CR>")
map("n", "<S-h>", ":bprevious<CR>")

-- Delete buffers
map("n", "<leader>bd", ":BufDel<CR>")

-- Better window navigation
map("n", "<C-h>", "<C-w><C-h>", "Navigate windows to the left")
map("n", "<C-j>", "<C-w><C-j>", "Navigate windows down")
map("n", "<C-k>", "<C-w><C-k>", "Navigate windows up")
map("n", "<C-l>", "<C-w><C-l>", "Navigate windows to the right")
