return {
  {
    "hrsh7th/nvim-cmp",
    version = false,
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "saadparwaiz1/cmp_luasnip",
      {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build = "make install_jsregexp",
        dependencies = { "rafamadriz/friendly-snippets" },
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
          require("luasnip").filetype_extend("typescript", { "javascript" })
          require("luasnip").filetype_extend("typescriptreact", { "javascript", "typescript" })
          require("luasnip").filetype_extend("vue", { "javascript", "typescript", "html" })
          require("luasnip").filetype_extend("php", { "html" })
        end,
      },
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "nvim_lsp_signature_help", priority = 900 },
          { name = "luasnip", priority = 750 },
          { name = "lazydev", group_index = 0 }, -- neovim lua API
          { name = "path", priority = 500 },
        }, {
          { name = "buffer", priority = 250 },
        }),
        formatting = {
          format = function(entry, item)
            local icons = {
              Array         = " ", Boolean       = "󰨙 ", Class         = " ",
              Codeium       = "󰘦 ", Color         = " ", Control       = " ",
              Collapsed     = " ", Constant       = "󰏿 ", Constructor   = " ",
              Copilot       = " ", Enum           = " ", EnumMember    = " ",
              Event         = " ", Field          = " ", File          = " ",
              Folder        = " ", Function       = "󰊕 ", Interface     = " ",
              Key           = " ", Keyword        = " ", Method        = "󰊕 ",
              Module        = " ", Namespace      = "󰦮 ", Null          = "󰟢 ",
              Number        = "󰎠 ", Object         = " ", Operator      = " ",
              Package       = " ", Property       = " ", Reference     = " ",
              Snippet       = "󱄽 ", String         = " ", Struct        = "󰆼 ",
              TabNine       = "󰏚 ", Text          = " ", TypeParameter = " ",
              Unit          = " ", Value          = " ", Variable      = "󰀫 ",
            }
            if icons[item.kind] then
              item.kind = icons[item.kind] .. item.kind
            end
            local source_labels = {
              buffer = "[Buf]",
              nvim_lsp = "[LSP]",
              luasnip = "[Snip]",
              path = "[Path]",
              lazydev = "[Lazy]",
              ["vim-dadbod-completion"] = "[DB]",
            }
            item.menu = source_labels[entry.source.name] or string.format("[%s]", entry.source.name)
            return item
          end,
        },
        experimental = { ghost_text = { hl_group = "CmpGhostText" } },
      })

      -- SQL-specific sources (dadbod)
      cmp.setup.filetype({ "sql", "mysql", "plsql" }, {
        sources = cmp.config.sources({
          { name = "vim-dadbod-completion" },
        }, {
          { name = "buffer" },
        }),
      })

      -- Cmdline completion for /
      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "buffer" } },
      })

      -- Cmdline completion for :
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
        matching = { disallow_symbol_nonprefix_matching = false },
      })
    end,
  },
}
