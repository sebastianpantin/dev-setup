local H = dofile(vim.fn.getcwd() .. "/tests/integration/helpers.lua")
local eq = MiniTest.expect.equality

local child = H.new_child()
local T = H.new_set(child)

T[":checkhealth"] = MiniTest.new_set({
	parametrize = { { "lazy" }, { "mason" }, { "which-key" }, { "nvim-treesitter" }, { "vim.lsp" } },
})

-- Warnings depend on what else is installed (Go, PHP, ...), so only errors fail
T[":checkhealth"]["reports no errors"] = function(name)
	child.cmd("checkhealth " .. name)
	eq(child.bo.filetype, "checkhealth")
	local errors = vim.tbl_filter(function(line)
		return line:find("ERROR", 1, true) ~= nil
	end, child.lines())
	eq(errors, {})
end

return T
