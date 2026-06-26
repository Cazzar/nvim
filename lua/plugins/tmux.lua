return {
  -- Seamless navigation between nvim splits and tmux panes
  -- Requires tmux plugin: https://github.com/christoomey/vim-tmux-navigator
  -- Add to tmux.conf:
  --   set -g @plugin 'christoomey/vim-tmux-navigator'
  --   run '~/.tmux/plugins/tpm/tpm'
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>",     desc = "Tmux/nvim left" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>",     desc = "Tmux/nvim down" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>",       desc = "Tmux/nvim up" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>",    desc = "Tmux/nvim right" },
      { "<C-\\>","<cmd>TmuxNavigatePrevious<cr>", desc = "Tmux/nvim previous" },
    },
    init = function()
      vim.g.tmux_navigator_no_mappings = 1
      vim.g.tmux_navigator_save_on_switch = 2
      vim.g.tmux_navigator_disable_when_zoomed = 1
    end,
  },
}
