return {
	"j-hui/fidget.nvim",
	event = "LspAttach",
	opts = {
		progress = {
			display = {
				overrides = {
					fsautocomplete = {
						name = "F# LSP",
						update_hook = function(item)
							require("fidget.notification").set_content_key(item)
							if
								(item.hidden == nil or item.hidden == false)
								and string.match(item.annote, "Typechecking")
							then
								item.hidden = true
							end
						end,
					},
				},
			},
		},
	},
}
