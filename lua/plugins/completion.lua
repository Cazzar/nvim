return {
  {
    "saghen/blink.cmp",
    version = "*",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "rafamadriz/friendly-snippets",
      {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build = vim.fn.has("win32") == 0 and "make install_jsregexp" or nil,
        config = function()
          local ls = require("luasnip")
          require("luasnip.loaders.from_vscode").lazy_load()
          ls.filetype_extend("typescript", { "javascript" })
          ls.filetype_extend("typescriptreact", { "javascript", "typescript" })
          ls.filetype_extend("vue", { "javascript", "typescript", "html" })
          ls.filetype_extend("php", { "html" })
        end,
      },
    },
    opts = {
      snippets = { preset = "luasnip" },

      keymap = {
        preset = "none",
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
        ["<C-n>"] = { "select_next", "show" },
        ["<C-p>"] = { "select_prev", "show" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
      },

      appearance = {
        nerd_font_variant = "mono",
        kind_icons = {
          Array = " ", Boolean = "󰨙 ", Class = " ",
          Color = " ", Constant = "󰏿 ", Constructor = " ",
          Enum = " ", EnumMember = " ", Event = " ",
          Field = " ", File = " ", Folder = " ",
          Function = "󰊕 ", Interface = " ", Key = " ",
          Keyword = " ", Method = "󰊕 ", Module = " ",
          Namespace = "󰦮 ", Null = "󰟢 ", Number = "󰎠 ",
          Object = " ", Operator = " ", Package = " ",
          Property = " ", Reference = " ", Snippet = "󱄽 ",
          String = " ", Struct = "󰆼 ", TypeParameter = " ",
          Unit = " ", Value = " ", Variable = "󰀫 ",
        },
      },

      sources = {
        default = { "lsp", "path", "snippets", "buffer", "lazydev" },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
          dadbod = {
            name = "Dadbod",
            module = "vim_dadbod_completion.blink",
          },
        },
        per_filetype = {
          sql   = { "dadbod", "snippets", "buffer" },
          mysql = { "dadbod", "snippets", "buffer" },
          plsql = { "dadbod", "snippets", "buffer" },
        },
      },

      completion = {
        accept = { auto_brackets = { enabled = true } },
        ghost_text = { enabled = true },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = { border = "rounded" },
        },
        menu = {
          border = "rounded",
          draw = {
            columns = {
              { "label", "label_description", gap = 1 },
              { "kind_icon", "kind", gap = 1 },
            },
          },
        },
      },

      cmdline = { enabled = true },

      signature = {
        enabled = true,
        window = { border = "rounded" },
      },
    },
  },
}
