return {
	"atiladefreitas/dooing",
	cmd = { "Dooing", "DooingTodos", "DooingTasksToggle" },
	config = function()
		require("dooing").setup()
	end,
}
