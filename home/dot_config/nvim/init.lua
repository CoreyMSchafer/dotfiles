-- ~/.config/nvim/init.lua
-- Leader VOR den Plugins setzen
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- lazy.nvim bootstrappen
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", repo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({ { "lazy.nvim clone fehlgeschlagen:\n", "ErrorMsg" }, { out, "WarningMsg" } }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("config.options")

require("lazy").setup({
  spec = { { import = "plugins" } },
  install = { colorscheme = { "rose-pine" } },
  checker = { enabled = false },
  ui = { border = "rounded", backdrop = 100 },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin", "netrwPlugin",
      },
    },
  },
})

require("config.keymaps")
require("config.autocmds")
