-- Basis-Einstellungen (UI-lastig)
local opt = vim.opt

opt.termguicolors = true
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.laststatus = 3          -- eine globale Statusline
opt.cmdheight = 0           -- Cmdline wird von noice gerendert
opt.showmode = false        -- Modus steht in der Statusline
opt.pumheight = 12
opt.pumblend = 10
opt.winminwidth = 5

opt.scrolloff = 8
opt.sidescrolloff = 8
opt.smoothscroll = true
opt.splitbelow = true
opt.splitright = true
opt.splitkeep = "screen"

opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.undofile = true
opt.swapfile = false
opt.updatetime = 200
opt.timeoutlen = 400
opt.confirm = true

opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true

opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split"

opt.wrap = false
opt.list = true
opt.listchars = { tab = "→ ", trail = "·", nbsp = "␣", extends = "…", precedes = "…" }
opt.fillchars = {
  eob = " ",
  foldopen = "▾",
  foldclose = "▸",
  fold = " ",
  foldsep = " ",
  diff = "╱",
}

opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldtext = ""

opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.completeopt = "menu,menuone,noselect"

vim.g.markdown_recommended_style = 0
