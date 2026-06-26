-- nvim-treesitter was fully rewritten; requires Neovim 0.12+ and does NOT support lazy-loading.
-- Highlighting, folding, and indentation are now Neovim built-ins — treesitter provides parsers/queries.
-- Textobjects plugin has its own standalone setup API (not via nvim-treesitter.configs).
return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false, -- explicit: plugin README states it does not support lazy-loading
    build = ":TSUpdate",
    config = function()
      -- Install all parsers (async, no-op if already up to date)
      require("nvim-treesitter").install({
        "bash",
        "c_sharp",
        "css",
        "diff",
        "dockerfile",
        "gitcommit",
        "gitignore",
        "git_rebase",
        "graphql",
        "html",
        "javascript",
        "jsdoc",
        "json",
        "json5",
        "jsonc",
        "lua",
        "luadoc",
        "markdown",
        "markdown_inline",
        "php",
        "phpdoc",
        "regex",
        "rust",
        "scss",
        "sql",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "vue",
        "xml",
        "yaml",
      })

      -- Enable treesitter highlighting + indentation for every filetype
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter_attach", { clear = true }),
        callback = function(ev)
          if vim.bo[ev.buf].filetype == "" then return end
          pcall(vim.treesitter.start, ev.buf)
          vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },

  -- Textobjects: standalone plugin with its own setup (not via nvim-treesitter.configs)
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    lazy = false,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move  = { set_jumps = true },
      })

      local sel  = require("nvim-treesitter-textobjects.select")
      local mv   = require("nvim-treesitter-textobjects.move")
      local swap = require("nvim-treesitter-textobjects.swap")

      -- Text object selections
      local selections = {
        ["af"] = "@function.outer", ["if"] = "@function.inner",
        ["ac"] = "@class.outer",    ["ic"] = "@class.inner",
        ["aa"] = "@parameter.outer",["ia"] = "@parameter.inner",
        ["ai"] = "@conditional.outer", ["ii"] = "@conditional.inner",
        ["al"] = "@loop.outer",     ["il"] = "@loop.inner",
        ["ab"] = "@block.outer",    ["ib"] = "@block.inner",
      }
      for key, query in pairs(selections) do
        vim.keymap.set({ "x", "o" }, key, function()
          sel.select_textobject(query, "textobjects")
        end, { desc = "Select " .. query })
      end

      -- Motion keymaps
      local motions = {
        { "]f", "goto_next_start",     "@function.outer"  },
        { "]c", "goto_next_start",     "@class.outer"     },
        { "]a", "goto_next_start",     "@parameter.inner" },
        { "]F", "goto_next_end",       "@function.outer"  },
        { "]C", "goto_next_end",       "@class.outer"     },
        { "[f", "goto_previous_start", "@function.outer"  },
        { "[c", "goto_previous_start", "@class.outer"     },
        { "[a", "goto_previous_start", "@parameter.inner" },
        { "[F", "goto_previous_end",   "@function.outer"  },
        { "[C", "goto_previous_end",   "@class.outer"     },
      }
      for _, m in ipairs(motions) do
        local key, fn, query = m[1], m[2], m[3]
        vim.keymap.set({ "n", "x", "o" }, key, function()
          mv[fn]({ query }, "textobjects")
        end, { desc = fn:gsub("_", " ") .. " " .. query })
      end

      -- Swap keymaps
      vim.keymap.set("n", "<leader>csa", function()
        swap.swap_next({ "@parameter.inner" }, "textobjects")
      end, { desc = "Swap next parameter" })
      vim.keymap.set("n", "<leader>csA", function()
        swap.swap_previous({ "@parameter.inner" }, "textobjects")
      end, { desc = "Swap prev parameter" })
    end,
  },

  -- Sticky context header at top of window
  {
    "nvim-treesitter/nvim-treesitter-context",
    lazy = false,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      enable = true,
      max_lines = 4,
      min_window_height = 20,
      mode = "cursor",
    },
    keys = {
      { "<leader>ut", "<cmd>TSContextToggle<cr>", desc = "Toggle treesitter context" },
      {
        "[x",
        function() require("treesitter-context").go_to_context(vim.v.count1) end,
        silent = true,
        desc = "Jump to context",
      },
    },
  },

  -- Auto-close/rename HTML, Vue, JSX tags
  {
    "windwp/nvim-ts-autotag",
    lazy = false,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {},
  },

  -- Markdown rendering
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ft = { "markdown", "mdx" },
    opts = {
      render_modes = { "n", "c" },
      heading = { enabled = true },
      code = { enabled = true, sign = false, width = "block", right_pad = 1 },
      dash = { enabled = true },
      bullet = { enabled = true },
      checkbox = { enabled = true },
      quote = { enabled = true },
      pipe_table = { enabled = true },
      link = { enabled = true },
    },
    keys = {
      { "<leader>um", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle Markdown rendering" },
    },
  },
}
