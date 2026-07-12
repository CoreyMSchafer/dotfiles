-- ~/.config/nvim/lua/plugins/zk.lua
-- zk-nvim: Neovim-Integration für den zk-Zettelkasten
-- Repo: https://github.com/zk-org/zk-nvim
return {
  "zk-org/zk-nvim",
  event = "VeryLazy",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    require("zk").setup({
      -- Picker: "telescope" | "fzf_lua" | "snacks_picker" | "minipick" | "select"
      picker = "telescope",
      lsp = {
        config = {
          name = "zk",
          cmd = { "zk", "lsp" },
          on_attach = function(_, bufnr)
            local b = { buffer = bufnr, noremap = true, silent = false }
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, b)
            vim.keymap.set("n", "K", vim.lsp.buf.hover, b)
            vim.keymap.set("n", "<leader>zb", "<Cmd>ZkBacklinks<CR>", b)
            vim.keymap.set("n", "<leader>zl", "<Cmd>ZkLinks<CR>", b)
            vim.keymap.set("n", "<leader>zi", "<Cmd>ZkInsertLink<CR>", b)
            vim.keymap.set("v", "<leader>zi", ":'<,'>ZkInsertLinkAtSelection<CR>", b)
            vim.keymap.set("v", "<leader>zn", ":'<,'>ZkNewFromTitleSelection<CR>", b)
          end,
        },
        auto_attach = { enabled = true, filetypes = { "markdown" } },
      },
    })

    local map = vim.keymap.set
    local opts = { noremap = true, silent = false }

    -- Neue Notiz in deinen Bereichen (von überall)
    map("n", "<leader>zd", function()
      require("zk").new({ dir = "diss", title = vim.fn.input("Titel diss: ") })
    end, opts)
    map("n", "<leader>za", function()
      require("zk").new({ dir = "ap", title = vim.fn.input("Titel ap: ") })
    end, opts)
    map("n", "<leader>zp", function()
      require("zk").new({ dir = "p", title = vim.fn.input("Titel p: ") })
    end, opts)

    -- Suchen & Öffnen
    map("n", "<leader>zo", "<Cmd>ZkNotes { sort = { 'modified' } }<CR>", opts)
    map("n", "<leader>zf",
      "<Cmd>ZkNotes { sort = { 'modified' }, match = { vim.fn.input('Volltext: ') } }<CR>", opts)
    map("v", "<leader>zf", ":'<,'>ZkMatch<CR>", opts)
    map("n", "<leader>zt", "<Cmd>ZkTags<CR>", opts)
  end,
}
