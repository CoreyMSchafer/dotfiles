-- Schlankes LSP: CC schreibt den Code, LSP gibt dir Diagnostics/Hover/Rename
-- beim Reviewen. mason installiert die Server automatisch.
-- HINWEIS: Das ist der Teil, der bei nvim 0.11/0.12 am ehesten eine kleine
-- Anpassung braucht (LSP-API im Umbruch). Läuft's nicht sofort: kurz melden.
return {
  { "williamboman/mason.nvim", opts = {} },
  {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig", "saghen/blink.cmp" },
    opts = { ensure_installed = { "lua_ls", "pyright", "ts_ls", "bashls" } },
    config = function(_, opts)
      require("mason-lspconfig").setup(opts)  -- automatic_enable=true -> vim.lsp.enable
      -- blink-Capabilities global für alle Server
      pcall(function()
        vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })
      end)
      vim.diagnostic.config({ virtual_text = true, severity_sort = true })
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("sn_lsp", { clear = true }),
        callback = function(ev)
          local b = { buffer = ev.buf }
          vim.keymap.set("n", "gd",  vim.lsp.buf.definition,  b)
          vim.keymap.set("n", "K",   vim.lsp.buf.hover,       b)
          vim.keymap.set("n", "grn", vim.lsp.buf.rename,      b)
          vim.keymap.set("n", "gra", vim.lsp.buf.code_action, b)
          vim.keymap.set("n", "grr", vim.lsp.buf.references,  b)
        end,
      })
    end,
  },
  {
    "saghen/blink.cmp",
    version = "*",
    event = "InsertEnter",
    opts = {
      keymap = { preset = "default" },
      sources = { default = { "lsp", "path", "buffer" } },
    },
  },
}
