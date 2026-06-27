-- Interactive SQL/DB UI via vim-dadbod
-- Connections are machine-local — add them via :DBUIAddConnection (saved to stdpath("data"))
-- or define vim.g.dbs in post-init.local.lua for pre-configured connections:
return {
  {
    "tpope/vim-dadbod",
    lazy = true,
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      "tpope/vim-dadbod",
      { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
    },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    keys = {
      { "<leader>Du", "<cmd>DBUIToggle<cr>", desc = "DB UI toggle" },
      { "<leader>Da", "<cmd>DBUIAddConnection<cr>", desc = "DB add connection" },
      { "<leader>Df", "<cmd>DBUIFindBuffer<cr>", desc = "DB find buffer" },
    },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/dadbod-ui"
      vim.g.db_ui_show_database_icon = 1
      vim.g.db_ui_force_echo_notifications = 1
      vim.g.db_ui_win_position = "left"
      vim.g.db_ui_winwidth = 40
      -- Execute mapped to <leader>S in SQL buffers
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql", "plsql" },
        callback = function(event)
          vim.keymap.set(
            { "n", "v" },
            "<leader>DS",
            "<Plug>(DBUI_ExecuteQuery)",
            { buffer = event.buf, desc = "DB execute query" }
          )
          vim.keymap.set(
            "n",
            "<leader>DE",
            "<Plug>(DBUI_EditBindParameters)",
            { buffer = event.buf, desc = "DB edit parameters" }
          )
          vim.keymap.set(
            "n",
            "<leader>DS",
            "<Plug>(DBUI_SaveQuery)",
            { buffer = event.buf, desc = "DB save query" }
          )
        end,
      })
    end,
  },
}
