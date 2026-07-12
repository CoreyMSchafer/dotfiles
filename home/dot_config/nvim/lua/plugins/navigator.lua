-- C-h/j/k/l navigiert nahtlos zwischen nvim-Splits UND tmux-Panes.
-- Gegenstück in ~/.tmux.conf (Plugin christoomey/vim-tmux-navigator).
return {
  {
    "christoomey/vim-tmux-navigator",
    cmd = { "TmuxNavigateLeft", "TmuxNavigateDown", "TmuxNavigateUp", "TmuxNavigateRight" },
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>",  desc = "Nav links" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>",  desc = "Nav unten" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>",    desc = "Nav oben" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Nav rechts" },
    },
  },
}
