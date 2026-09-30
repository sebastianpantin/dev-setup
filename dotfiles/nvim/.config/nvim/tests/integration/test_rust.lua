-- Uses rust-analyzer, installed into the test environment by tests/run.sh,
-- and the Rust toolchain (cargo, rustc and clippy, see lsp/rust_analyzer.lua).
local H = dofile(vim.fn.getcwd() .. "/tests/integration/helpers.lua")

-- Loading the workspace (cargo metadata, the sysroot) takes a while
local LSP_TIMEOUT = 60000
local main_file = H.fixture("rust_project/src/main.rs")

local child = H.new_child()
local T = H.new_set(child)

-- Open `file` and wait until rust_analyzer has attached to it.
local function open_with_lsp(file)
	-- Without these, rust_analyzer never gets going and tests only time out
	for _, exe in ipairs({ "cargo", "cargo-clippy" }) do
		assert(vim.fn.executable(exe) == 1, exe .. " not found: install the Rust toolchain with clippy")
	end
	child.cmd("edit " .. vim.fn.fnameescape(file))
	H.wait_for(child, "#vim.lsp.get_clients({ bufnr = 0, name = 'rust_analyzer' }) > 0", LSP_TIMEOUT)
end

-- Wait for a diagnostic from `source` with `code` in the current buffer.
local function wait_for_diagnostic(source, code)
	local expr = "vim.iter(vim.diagnostic.get(0)):any(function(d) return d.source == %q and d.code == %q end)"
	H.wait_for(child, expr:format(source, code), LSP_TIMEOUT)
end

T["rust_analyzer reports its own diagnostics"] = function()
	open_with_lsp(main_file)
	wait_for_diagnostic("rust-analyzer", "inactive_code")
end

T["clippy is the check command"] = function()
	open_with_lsp(main_file)
	wait_for_diagnostic("clippy", "needless_return")
end

T["hover returns the signature"] = function()
	open_with_lsp(main_file)
	child.api.nvim_win_set_cursor(0, { 15, 18 }) -- on the `greet("world")` call
	-- Like lua_ls, hovers are empty until the workspace has loaded, so poll
	child.lua([[
		_G.hover_text = function()
			local params = vim.lsp.util.make_position_params(0, "utf-16")
			for _, res in pairs(vim.lsp.buf_request_sync(0, "textDocument/hover", params, 5000) or {}) do
				if res.result then
					return res.result.contents.value
				end
			end
			return ""
		end
	]])
	H.wait_for(child, "_G.hover_text():find('fn greet(name: &str) -> String', 1, true) ~= nil", LSP_TIMEOUT)
end

return T
