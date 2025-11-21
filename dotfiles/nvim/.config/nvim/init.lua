vim.g.python3_host_prog = vim.fn.expand("$HOME/.pyenv/versions/neovim3/bin/python")
-- Handle plugins with lazy.nvim
require("core.lazy")

-- General Neovim keymaps
require("core.keymaps")

-- Other options
require("core.options")
