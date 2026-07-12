return {
  -- Icons
  { "nvim-tree/nvim-web-devicons", lazy = true },
  { "MunifTanjim/nui.nvim", lazy = true },

  -- Snacks: Dashboard, Notifier, Indent-Guides, Scroll, Statuscolumn, Input, Zen-Zoom
  {
    "folke/snacks.nvim",
    priority = 900,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      quickfile = { enabled = true },
      input = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
      notifier = {
        enabled = true,
        timeout = 3000,
        style = "compact",
      },
      indent = {
        enabled = true,
        indent = { char = "│" },
        scope = { char = "│", hl = "SnacksIndentScope" },
        animate = { enabled = true, duration = { step = 15, total = 250 } },
      },
      dashboard = {
        enabled = true,
        preset = {
          header = [[
                                                    
      ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗
      ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║
      ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║
      ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║
      ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║
      ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝
                                                    
]],
          keys = {
            { icon = " ", key = "f", desc = "Datei suchen", action = "<Cmd>Telescope find_files<CR>" },
            { icon = " ", key = "n", desc = "Neue Datei", action = ":ene | startinsert" },
            { icon = " ", key = "g", desc = "Volltextsuche", action = "<Cmd>Telescope live_grep<CR>" },
            { icon = " ", key = "r", desc = "Zuletzt geöffnet", action = "<Cmd>Telescope oldfiles<CR>" },
            { icon = "󰎚 ", key = "z", desc = "Zettelkasten", action = "<Cmd>ZkNotes { sort = { 'modified' } }<CR>" },
            { icon = " ", key = "c", desc = "Config", action = "<Cmd>e $MYVIMRC<CR>" },
            { icon = "󰒲 ", key = "l", desc = "Lazy", action = "<Cmd>Lazy<CR>" },
            { icon = " ", key = "q", desc = "Beenden", action = ":qa" },
          },
        },
        sections = {
          { section = "header" },
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
        },
      },
      styles = {
        notification = { wo = { wrap = true } },
      },
    },
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function()
      return {
        options = {
          theme = "auto",
          globalstatus = true,
          component_separators = { left = "│", right = "│" },
          section_separators = { left = "", right = "" },
          disabled_filetypes = { statusline = { "snacks_dashboard" } },
        },
        sections = {
          lualine_a = { { "mode", separator = { left = "" }, right_padding = 2 } },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = {
            { "filename", path = 1, symbols = { modified = " ●", readonly = " " } },
          },
          lualine_x = {
            {
              function()
                local ok, wc = pcall(vim.fn.wordcount)
                if ok and wc.words and wc.words > 0 then
                  return "󰈭 " .. wc.words
                end
                return ""
              end,
              cond = function()
                return vim.tbl_contains({ "markdown", "text", "tex" }, vim.bo.filetype)
              end,
            },
            "encoding",
            "filetype",
          },
          lualine_y = { "progress" },
          lualine_z = { { "location", separator = { right = "" }, left_padding = 2 } },
        },
        extensions = { "lazy", "quickfix", "man" },
      }
    end,
  },

  -- Hübsche Cmdline, Messages, LSP-Hover
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
      },
      presets = {
        bottom_search = false,
        command_palette = true,
        long_message_to_split = true,
        lsp_doc_border = true,
      },
      cmdline = {
        format = {
          cmdline = { icon = "" },
          search_down = { icon = " " },
          search_up = { icon = " " },
        },
      },
      routes = {
        { filter = { event = "msg_show", find = "written" }, opts = { skip = true } },
        { filter = { event = "msg_show", kind = "search_count" }, opts = { skip = true } },
      },
    },
  },

  -- Keymap-Hilfe
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      win = { border = "rounded" },
      spec = {
        { "<leader>w", group = "Schreiben / Speichern" },
        { "<leader>z", group = "Zettelkasten" },
        { "<leader>u", group = "UI" },
        { "<leader>f", group = "Finden" },
        { "<leader>g", group = "Git" },
        { "<leader>c", group = "Claude Code" },
      },
    },
  },

  -- Git-Zeichen in der Signcolumn
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      current_line_blame = false,
    },
    keys = {
      { "<leader>gb", "<Cmd>Gitsigns toggle_current_line_blame<CR>", desc = "Blame an/aus" },
      { "<leader>gp", "<Cmd>Gitsigns preview_hunk<CR>", desc = "Hunk ansehen" },
      { "]h", "<Cmd>Gitsigns next_hunk<CR>", desc = "Nächster Hunk" },
      { "[h", "<Cmd>Gitsigns prev_hunk<CR>", desc = "Vorheriger Hunk" },
    },
  },

  -- TODO/FIXME hervorheben
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = true },
  },
}
