return {
  {
    "adalessa/laravel.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
    },
    ft = { "php", "blade" },
    cmd = { "Laravel" },
    keys = {
      { "<leader>la", "<cmd>Laravel artisan<cr>", desc = "Artisan commands" },
      { "<leader>lr", "<cmd>Laravel routes<cr>", desc = "Laravel routes" },
      { "<leader>lm", "<cmd>Laravel related<cr>", desc = "Related files" },
    },
    init = function()
      vim.filetype.add({ pattern = { [".*%.blade%.php"] = "blade" } })
    end,
    opts = {
      lsp_server = "intelephense",
    },
  },
}
