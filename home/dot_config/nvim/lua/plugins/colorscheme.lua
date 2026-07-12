-- Warme, gedämpfte Themes. Default: Rose Pine.
-- variant = "auto" -> folgt vim.o.background (main = dunkel, dawn = hell).
-- Umschalten passiert automatisch via lua/plugins/autodark.lua (macOS Hell/Dunkel).
-- Manuell durchprobieren: <leader>uc (Telescope-Picker mit Live-Preview)
return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000,
    opts = {
      variant = "auto",       -- auto | main | moon | dawn
      dark_variant = "main",  -- dunkler Modus = Rosé Pine Main
      dim_inactive_windows = true,
      extend_background_behind_borders = true,
      styles = {
        bold = true,
        italic = true,
        transparency = false,
      },
      highlight_groups = {
        CursorLine = { bg = "overlay" },
        Search = { bg = "gold", fg = "base", inherit = false },
        IncSearch = { bg = "rose", fg = "base", inherit = false },
        Visual = { bg = "highlight_med", inherit = false },
        FloatBorder = { fg = "muted", bg = "none" },
        NormalFloat = { bg = "surface" },
        WinSeparator = { fg = "overlay" },
        ["@markup.heading.1.markdown"] = { fg = "love", bold = true },
        ["@markup.heading.2.markdown"] = { fg = "gold", bold = true },
        ["@markup.heading.3.markdown"] = { fg = "rose", bold = true },
        ["@markup.heading.4.markdown"] = { fg = "pine", bold = true },
      },
    },
    config = function(_, opts)
      require("rose-pine").setup(opts)
      vim.cmd.colorscheme("rose-pine")
    end,
  },

  -- Alternativen zum Durchprobieren
  { "rebelot/kanagawa.nvim", lazy = true, opts = { theme = "wave", dimInactive = true } },
  { "catppuccin/nvim", name = "catppuccin", lazy = true, opts = { flavour = "mocha" } },
  { "vague2k/vague.nvim", lazy = true, opts = {} },
}
