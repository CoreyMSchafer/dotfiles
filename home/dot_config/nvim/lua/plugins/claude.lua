-- Claude Code als vollwertiges nvim-IDE:
--  • gleicher WebSocket/MCP-Kanal wie die VS-Code-Extension
--  • Inline-Diffs in nvim (bearbeitbar, mit :w bzw. <leader>ca annehmen)
--  • CC läuft in einem echten tmux-Pane (claude-tmux.nvim)
return {
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim", "mr55p-dev/claude-tmux.nvim" },
    keys = {
      { "<leader>cc", "<cmd>ClaudeCode<cr>",            desc = "Claude öffnen/toggeln" },
      { "<leader>cs", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Auswahl an Claude senden" },
      { "<leader>ca", "<cmd>ClaudeCodeDiffAccept<cr>",  desc = "Diff annehmen" },
      { "<leader>cx", "<cmd>ClaudeCodeCloseAllDiffs<cr>", desc = "Alle Diffs schließen" },
    },
    opts = function()
      -- CC in einem tmux-Pane statt im nvim-Fenster.
      -- toggle_key = nil: Rücksprung übernimmt vim-tmux-navigator (C-h/j/k/l).
      local terminal = {}
      local ok, tmux = pcall(require, "claude-tmux")
      if ok and tmux.is_available() then
        terminal.provider = tmux.setup({ toggle_key = nil, split_size = 35 })
      end
      return { terminal = terminal }
    end,
  },
  { "mr55p-dev/claude-tmux.nvim", lazy = true },
}
