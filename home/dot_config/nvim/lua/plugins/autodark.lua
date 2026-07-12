-- nvim folgt der macOS-Erscheinung: dunkel -> Rosé Pine Main, hell -> Dawn.
-- Zusammen mit variant="auto" in colorscheme.lua.
return {
  {
    "f-person/auto-dark-mode.nvim",
    lazy = false,
    priority = 2000,
    opts = {
      update_interval = 3000,
      set_dark_mode = function()
        vim.o.background = "dark"
        pcall(vim.cmd.colorscheme, "rose-pine")
      end,
      set_light_mode = function()
        vim.o.background = "light"
        pcall(vim.cmd.colorscheme, "rose-pine")
      end,
    },
  },
}
