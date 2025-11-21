return {
	-- Override deprecated default settings
	cmd = { "fsautocomplete", "--background-service-enabled" },
	root_dir = require("lspconfig.util").root_pattern("*.sln", "*.fsproj", ".git"),
	init_options = {
		AutomaticWorkspaceInit = true,
	},
	settings = {},
}
