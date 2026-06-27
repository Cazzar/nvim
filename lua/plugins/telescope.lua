return {
  {
    "nvim-telescope/telescope.nvim",
    version = false,
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
        enabled = vim.fn.executable("cmake") == 1,
      },
      "nvim-telescope/telescope-ui-select.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      -- Files
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fF", "<cmd>Telescope find_files hidden=true<cr>", desc = "Find files (hidden)" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>fw", "<cmd>Telescope grep_string<cr>", desc = "Grep word under cursor" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
      { "<leader>fb", "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>", desc = "Buffers" },

      -- Git
      { "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Git commits" },
      { "<leader>gC", "<cmd>Telescope git_bcommits<cr>", desc = "Git buffer commits" },
      { "<leader>gb", "<cmd>Telescope git_branches<cr>", desc = "Git branches" },
      { "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Git status" },
      { "<leader>gS", "<cmd>Telescope git_stash<cr>", desc = "Git stash" },

      -- LSP (also in lsp.lua via on_attach, these work before attach)
      { "<leader>fs", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", desc = "Find symbol (workspace)" },
      { "<leader>ss", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document symbols" },
      { "<leader>sS", "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "Workspace symbols" },

      -- Misc
      { "<leader>:", "<cmd>Telescope command_history<cr>", desc = "Command history" },
      { "<leader>/", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Fuzzy find in buffer" },
      { "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
      { "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Help pages" },
      { "<leader>sm", "<cmd>Telescope marks<cr>", desc = "Marks" },
      { "<leader>sd", "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Document diagnostics" },
      { "<leader>sD", "<cmd>Telescope diagnostics<cr>", desc = "Workspace diagnostics" },
      { "<leader>sc", "<cmd>Telescope commands<cr>", desc = "Commands" },
    },
    opts = function()
      local actions = require("telescope.actions")
      return {
        defaults = {
          prompt_prefix = "  ",
          selection_caret = " ",
          entry_prefix = "  ",
          sorting_strategy = "ascending",
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = { prompt_position = "top", preview_width = 0.55 },
            vertical = { mirror = false },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
          },
          path_display = { "truncate" },
          mappings = {
            i = {
              ["<C-n>"] = actions.cycle_history_next,
              ["<C-p>"] = actions.cycle_history_prev,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["<Esc>"] = actions.close,
            },
          },
          file_ignore_patterns = {
            "node_modules", ".git/", "dist/", "build/", "vendor/",
            "%.lock", "package-lock%.json",
          },
          vimgrep_arguments = {
            "rg", "--color=never", "--no-heading", "--with-filename",
            "--line-number", "--column", "--smart-case", "--hidden",
            "--glob=!.git/",
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            find_command = { "fd", "--type", "f", "--strip-cwd-prefix", "--hidden", "--exclude", ".git" },
          },
          buffers = {
            theme = "dropdown",
            previewer = false,
          },
          lsp_references = { theme = "dropdown", initial_mode = "normal" },
          lsp_definitions = { theme = "dropdown", initial_mode = "normal" },
          lsp_implementations = { theme = "dropdown", initial_mode = "normal" },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
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
