local hide_in_width = function()
	return vim.fn.winwidth(0) > 80
end

return {
	{
		"nvim-lualine/lualine.nvim",
		config = function()
			local colorscheme = require("helpers.colorscheme")
			local lualine_theme = colorscheme == "default" and "auto" or colorscheme
			local icons = { Error = " ", Warn = " ", Hint = " ", Info = " " }

			local diagnostics = {
				"diagnostics",
				sources = { "nvim_diagnostic" },
				sections = { "error", "warn" },
				symbols = { error = icons.Error, warn = icons.Warn },
				colored = true,
				update_in_insert = false,
				always_visible = true,
			}

			local diff = {
				"diff",
				cond = hide_in_width,
			}

			local filetype = {
				"filetype",
				icons_enabled = true,
			}

			local branch = {
				"branch",
				icons_enabled = true,
				icon = "",
			}

			local location = {
				"location",
				padding = 0,
			}

			local function split(input, delimiter)
				local arr = {}
				_ = string.gsub(input, "[^" .. delimiter .. "]+", function(w)
					table.insert(arr, w)
				end)
				return arr
			end

			local function get_venv()
				local venv = vim.env.VIRTUAL_ENV
				if venv then
					local params = split(venv, "/")
					return "(env:" .. params[#params - 1] .. ")"
				else
					return ""
				end
			end

			local spaces = function()
				return "spaces: " .. vim.api.nvim_buf_get_option(0, "shiftwidth")
			end

			require("lualine").setup({
				options = {
					theme = lualine_theme,
					component_separators = { left = "", right = "" },
					section_separators = { left = "", right = "" },
					disabled_filetypes = { "alpha", "dashboard", "lazy" },
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { branch, diagnostics },
					lualine_c = { get_venv, filetype },
					lualine_x = { diff, spaces, "encoding" },
					lualine_y = { location },
					lualine_z = { "progress" },
				},
				extensions = { "quickfix", "man", "fugitive" },
			})
		end,
	},
}
