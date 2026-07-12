return {
  -- Syntax-Highlighting (nvim-treesitter main branch, kompatibel mit nvim 0.12)
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup()
      local ensure = {
        "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline",
        "bash", "json", "yaml", "toml", "python", "javascript", "typescript",
        "html", "css", "regex", "diff", "gitcommit",
      }
      local missing = {}
      for _, lang in ipairs(ensure) do
        if not pcall(vim.treesitter.language.add, lang) then
          table.insert(missing, lang)
        end
      end
      if #missing > 0 then
        require("nvim-treesitter").install(missing)
      end
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("sn_treesitter", { clear = true }),
        callback = function(ev)
          local lang = vim.treesitter.language.get_lang(ev.match)
          if lang and pcall(vim.treesitter.language.add, lang) then
            pcall(vim.treesitter.start, ev.buf, lang)
          end
        end,
      })
    end,
  },

  -- Fuzzy-Finder
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make", cond = function()
        return vim.fn.executable("make") == 1
      end },
      "nvim-telescope/telescope-ui-select.nvim",
    },
    keys = {
      { "<leader>ff", "<Cmd>Telescope find_files<CR>", desc = "Dateien" },
      { "<leader>fg", "<Cmd>Telescope live_grep<CR>", desc = "Volltext" },
      { "<leader>fb", "<Cmd>Telescope buffers<CR>", desc = "Buffer" },
      { "<leader>fr", "<Cmd>Telescope oldfiles<CR>", desc = "Zuletzt" },
      { "<leader>fh", "<Cmd>Telescope help_tags<CR>", desc = "Hilfe" },
      { "<leader>fk", "<Cmd>Telescope keymaps<CR>", desc = "Keymaps" },
    },
    opts = function()
      local actions = require("telescope.actions")
      return {
        defaults = {
          prompt_prefix = "   ",
          selection_caret = " ",
          entry_prefix = "  ",
          sorting_strategy = "ascending",
          winblend = 0,
          borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = { prompt_position = "top", preview_width = 0.55 },
            width = 0.87,
            height = 0.80,
          },
          path_display = { "truncate" },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<Esc>"] = actions.close,
            },
          },
        },
        extensions = {
          ["ui-select"] = { require("telescope.themes").get_dropdown({}) },
        },
      }
    end,
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      pcall(telescope.load_extension, "fzf")
      pcall(telescope.load_extension, "ui-select")
    end,
  },
}
