-- Schreib-Plugins: Markdown-Rendering, Zen-Mode, LaTeX
return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ft = { "markdown" },
    opts = {
      render_modes = { "n", "c", "t" },
      anti_conceal = { enabled = true },
      heading = {
        sign = false,
        position = "inline",
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
        width = "block",
        left_pad = 0,
        right_pad = 2,
      },
      code = {
        sign = false,
        width = "block",
        left_pad = 2,
        right_pad = 2,
        border = "thick",
        language_pad = 2,
      },
      bullet = { icons = { "●", "○", "◆", "◇" } },
      checkbox = {
        unchecked = { icon = "󰄱 " },
        checked = { icon = "󰱒 " },
      },
      quote = { icon = "▐" },
      dash = { icon = "─" },
      pipe_table = { preset = "round" },
      link = {
        image = "󰥶 ",
        hyperlink = "󰌷 ",
      },
    },
  },
  {
    "folke/zen-mode.nvim",
    dependencies = { "folke/twilight.nvim" },
    cmd = "ZenMode",
    opts = {
      window = {
        backdrop = 0.95,
        width = 0.72,
        height = 1,
        options = {
          signcolumn = "no",
          number = false,
          relativenumber = false,
          cursorline = false,
          foldcolumn = "0",
          list = false,
        },
      },
      plugins = {
        options = { enabled = true, ruler = false, showcmd = false, laststatus = 0 },
        twilight = { enabled = true },
        gitsigns = { enabled = false },
        tmux = { enabled = true },
      },
    },
  },
  {
    "lervag/vimtex",
    ft = { "tex", "latex", "plaintex" },
    init = function()
      vim.g.vimtex_view_method = "skim"
      vim.g.vimtex_compiler_method = "latexmk"
    end,
  },
}
