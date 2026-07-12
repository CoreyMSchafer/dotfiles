local augroup = function(name)
  return vim.api.nvim_create_augroup("sn_" .. name, { clear = true })
end

-- Yank kurz hervorheben
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function() vim.hl.on_yank({ higroup = "Visual", timeout = 150 }) end,
})

-- Splits bei Terminal-Resize gleichmäßig verteilen
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup("resize_splits"),
  callback = function()
    local tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. tab)
  end,
})

-- Zur letzten Cursorposition springen
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(ev)
    local exclude = { "gitcommit" }
    if vim.tbl_contains(exclude, vim.bo[ev.buf].filetype) then return end
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    local lcount = vim.api.nvim_buf_line_count(ev.buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- ===== Prosa / Schreib-Einstellungen =====
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("prose"),
  pattern = { "markdown", "tex", "plaintex", "text", "gitcommit" },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = { "de", "en" }
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
    vim.opt_local.list = false
    vim.keymap.set("n", "j", "gj", { buffer = true, silent = true })
    vim.keymap.set("n", "k", "gk", { buffer = true, silent = true })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("markdown"),
  pattern = "markdown",
  callback = function()
    vim.opt_local.conceallevel = 2
    pcall(vim.treesitter.start)
  end,
})
