local map = vim.keymap.set

-- Fenster/Pane-Navigation (C-h/j/k/l) macht vim-tmux-navigator
-- (siehe lua/plugins/navigator.lua) — nahtlos nvim <-> tmux.
map("n", "<leader>-", "<C-w>s", { desc = "Split horizontal" })
map("n", "<leader>|", "<C-w>v", { desc = "Split vertikal" })

-- Buffer
map("n", "<S-h>", "<Cmd>bprevious<CR>", { desc = "Buffer zurück" })
map("n", "<S-l>", "<Cmd>bnext<CR>", { desc = "Buffer vor" })

-- Komfort
map("n", "<Esc>", "<Cmd>nohlsearch<CR>", { desc = "Suche-Highlight aus" })
map("v", "<", "<gv")
map("v", ">", ">gv")
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Zeilen runter" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Zeilen hoch" })
map("n", "<leader>w", "<Cmd>write<CR>", { desc = "Speichern" })
map("n", "<leader>q", "<Cmd>quit<CR>", { desc = "Schließen" })

-- Schreiben
map("n", "<leader>ws", "<Cmd>setlocal spell!<CR>", { desc = "Rechtschreibung an/aus" })
map("n", "<leader>wz", "<Cmd>ZenMode<CR>", { desc = "Zen-Mode" })

-- UI-Toggles
map("n", "<leader>uc", function()
  require("telescope.builtin").colorscheme({ enable_preview = true })
end, { desc = "Colorscheme wechseln" })
map("n", "<leader>un", function() Snacks.notifier.hide() end, { desc = "Notifications ausblenden" })
map("n", "<leader>uh", function() Snacks.notifier.show_history() end, { desc = "Notification-Historie" })
map("n", "<leader>uw", function()
  vim.opt_local.wrap = not vim.opt_local.wrap:get()
end, { desc = "Wrap an/aus" })
map("n", "<leader>ul", function()
  vim.opt_local.number = not vim.opt_local.number:get()
  vim.opt_local.relativenumber = not vim.opt_local.relativenumber:get()
end, { desc = "Zeilennummern an/aus" })
map("n", "<leader>uz", function() Snacks.zen.zoom() end, { desc = "Fenster zoomen" })
