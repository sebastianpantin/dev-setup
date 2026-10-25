-- Key spec that calls a function of nvim-dap by name
local function dap_key(lhs, method, desc)
	return {
		lhs,
		function()
			require("dap")[method]()
		end,
		desc = desc,
	}
end

return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"mfussenegger/nvim-dap-python",
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
		},
		keys = {
			dap_key("<leader>db", "toggle_breakpoint", "Toggle breakpoint"),
			{
				"<leader>dB",
				function()
					require("dap").set_breakpoint(vim.fn.input("Condition: "))
				end,
				desc = "Conditional breakpoint",
			},
			dap_key("<leader>dc", "continue", "Continue"),
			dap_key("<leader>dC", "run_to_cursor", "Run to cursor"),
			dap_key("<leader>di", "step_into", "Step into"),
			dap_key("<leader>do", "step_out", "Step out"),
			dap_key("<leader>dO", "step_over", "Step over"),
			dap_key("<leader>dl", "run_last", "Run last"),
			dap_key("<leader>dt", "terminate", "Terminate"),
			{
				"<leader>dr",
				function()
					require("dap").repl.toggle()
				end,
				desc = "Toggle REPL",
			},
			{
				"<leader>dw",
				function()
					require("dap.ui.widgets").hover()
				end,
				desc = "Hover value",
			},
			{
				"<leader>du",
				function()
					require("dapui").toggle()
				end,
				desc = "Toggle debug UI",
			},
		},
		config = function()
			local dap, dapui = require("dap"), require("dapui")

			-- debugpy from mason runs the adapter; the program itself runs on the project's .venv
			local dap_python = require("dap-python")
			dap_python.setup(
				vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "packages", "debugpy", "venv", "bin", "python")
			)
			dap_python.resolve_python = function()
				return require("helpers.util").venv_python(vim.uv.cwd())
			end

			dapui.setup()
			dap.listeners.after.event_initialized.dapui = dapui.open
			dap.listeners.before.event_terminated.dapui = dapui.close
			dap.listeners.before.event_exited.dapui = dapui.close
		end,
	},
}
