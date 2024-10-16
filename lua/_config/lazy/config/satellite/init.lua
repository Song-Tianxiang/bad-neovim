return {
	{
		"lewis6991/satellite.nvim",
		enabled = false,
		lazy = false,
		cmd = { "SatelliteEnable" },
		config = function()
			require("satellite").setup({})
		end,
	},
}
