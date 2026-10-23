local M = {}

-- Protected require that returns nil on failure
M.safe_require = function(module)
	local ok, result = pcall(require, module)
	if not ok then
		return nil
	end
	return result
end

-- Nearest .venv above path (uv's default location), or nil
local function find_venv(path)
	return vim.fs.find(".venv", { path = path, upward = true, type = "directory" })[1]
end

-- Python of the nearest .venv above path, or nil
M.venv_python = function(path)
	local venv = find_venv(path)
	local python = venv and vim.fs.joinpath(venv, "bin", "python")
	if python and vim.fn.executable(python) == 1 then
		return python
	end
	return nil
end

-- Which binary of a Python tool (ruff, mypy) to run for a file in path:
-- inside a project with a .venv, only the project's own version (nil if it does not
-- install the tool, so the tool is skipped); outside any project, the global one.
M.python_tool = function(path, name)
	local venv = find_venv(path)
	if not venv then
		return name
	end
	local bin = vim.fs.joinpath(venv, "bin", name)
	if vim.fn.executable(bin) == 1 then
		return bin
	end
	return nil
end

-- Get border configuration
M.get_border = function()
	local constants = require("core.constants")
	return constants.border_style
end

return M
