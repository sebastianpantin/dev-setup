vim.g.python3_host_prog = vim.fn.expand("$HOME/.pyenv/versions/neovim3/bin/python")

-- install-work-tools.sh puts the .NET SDKs in ~/.dotnet, and only the zsh setup
-- adds them to PATH. Omarchy's /usr/bin/dotnet has no SDK, so a Neovim started
-- outside zsh can't install or run csharp-language-server, fsautocomplete or
-- fantomas. Use ~/.dotnet whenever it exists.
local dotnet_root = vim.fn.expand("$HOME/.dotnet")
if vim.fn.executable(dotnet_root .. "/dotnet") == 1 then
	vim.env.DOTNET_ROOT = dotnet_root
	vim.env.PATH = dotnet_root .. ":" .. dotnet_root .. "/tools:" .. vim.env.PATH
end
-- Handle plugins with lazy.nvim
require("core.lazy")

-- General Neovim keymaps
require("core.keymaps")

-- Other options
require("core.options")
