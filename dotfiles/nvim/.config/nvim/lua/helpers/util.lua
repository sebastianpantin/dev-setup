local M = {}

-- Protected require that returns nil on failure
M.safe_require = function(module)
	local ok, result = pcall(require, module)
	if not ok then
		return nil
	end
	return result
end

-- Get border configuration
M.get_border = function()
	local constants = require("core.constants")
	return constants.border_style
end

return M
