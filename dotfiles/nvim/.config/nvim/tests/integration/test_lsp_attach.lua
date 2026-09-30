-- Per-server overrides in lua/plugins/lsp.lua's LspAttach handler, checked
-- against fake in-process servers so vtsls and ruff needn't be installed.
local H = dofile(vim.fn.getcwd() .. "/tests/integration/helpers.lua")
local eq = MiniTest.expect.equality

local child = H.new_child()
local T = H.new_set(child)

-- Start a fake server named `...[1]` with capabilities `...[2]` in the
-- current buffer; returns its client id.
local start_fake_server = [[
	local name, capabilities = ...
	local results = { initialize = { capabilities = capabilities }, ["textDocument/inlayHint"] = {} }
	return vim.lsp.start({
		name = name,
		cmd = function(dispatchers)
			local closing = false
			return {
				request = function(method, _, callback)
					callback(nil, results[method])
					return true, 1
				end,
				notify = function(method)
					if method == "exit" then
						dispatchers.on_exit(0, 0)
					end
					return true
				end,
				is_closing = function()
					return closing
				end,
				terminate = function()
					closing = true
				end,
			}
		end,
	})
]]

-- Open a plain text file (so no real server is enabled for it), start a fake
-- server `name` with formatting, hover and `extra` capabilities, and wait
-- until it has attached. Returns the client id.
local function attach_fake_server(name, extra)
	-- A new file loads nvim-lspconfig, which registers the LspAttach handler
	child.cmd("edit " .. vim.fn.fnameescape(vim.fn.tempname() .. ".txt"))
	local capabilities =
		vim.tbl_extend("force", { documentFormattingProvider = true, hoverProvider = true }, extra or {})
	local id = child.lua(start_fake_server, { name, capabilities })
	H.wait_for(child, ("#vim.lsp.get_clients({ bufnr = 0, id = %d }) > 0"):format(id))
	return id
end

local function capability(id, name)
	return child.lua_get(("vim.lsp.get_client_by_id(%d).server_capabilities.%s"):format(id, name))
end

local function inlay_hints_enabled()
	return child.lua_get("vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })")
end

T["vtsls leaves formatting to conform"] = function()
	local id = attach_fake_server("vtsls")
	eq(capability(id, "documentFormattingProvider"), false)
	eq(capability(id, "hoverProvider"), true)
end

T["ruff leaves hover to other servers"] = function()
	local id = attach_fake_server("ruff")
	eq(capability(id, "hoverProvider"), false)
	eq(capability(id, "documentFormattingProvider"), true)
end

T["inlay hints are enabled when the server supports them"] = function()
	attach_fake_server("fake", { inlayHintProvider = true })
	eq(inlay_hints_enabled(), true)
end

T["inlay hints stay off when the server doesn't support them"] = function()
	attach_fake_server("fake")
	eq(inlay_hints_enabled(), false)
end

return T
