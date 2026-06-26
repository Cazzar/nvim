-- Shared LSP on_attach: keymaps applied whenever an LSP attaches to a buffer
local function on_attach(_, bufnr)
  local map = function(keys, func, desc)
    vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
  end

  map("gd", require("telescope.builtin").lsp_definitions, "Go to definition")
  map("gD", vim.lsp.buf.declaration, "Go to declaration")
  map("gr", require("telescope.builtin").lsp_references, "Go to references")
  map("gI", require("telescope.builtin").lsp_implementations, "Go to implementation")
  map("gy", require("telescope.builtin").lsp_type_definitions, "Go to type definition")
  map("K", vim.lsp.buf.hover, "Hover documentation")
  map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
  map("<leader>ca", vim.lsp.buf.code_action, "Code action")
  map("<leader>cs", require("telescope.builtin").lsp_document_symbols, "Document symbols")
  map("<leader>cS", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Workspace symbols")
  map("<leader>ci", "<cmd>LspInfo<cr>", "LSP info")

  -- Inlay hints (Neovim 0.10+)
  local client = vim.lsp.get_client_by_id(vim.fn.bufnr())
  if vim.lsp.inlay_hint and client and client.supports_method("textDocument/inlayHint") then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    map("<leader>ch", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
    end, "Toggle inlay hints")
  end
end

-- Default capabilities (extended by nvim-cmp)
local function make_capabilities()
  local caps = vim.lsp.protocol.make_client_capabilities()
  caps = vim.tbl_deep_extend("force", caps, require("cmp_nvim_lsp").default_capabilities())
  return caps
end

-- Server configurations
local servers = {
  -- PHP
  intelephense = {
    settings = {
      intelephense = {
        stubs = {
          "apache", "bcmath", "bz2", "calendar", "com_dotnet", "core", "ctype", "curl",
          "date", "dba", "dom", "enchant", "exif", "ffi", "fileinfo", "filter", "fpm",
          "ftp", "gd", "gettext", "gmp", "hash", "iconv", "imap", "intl", "json",
          "ldap", "libxml", "mbstring", "meta", "mysqli", "oci8", "odbc", "openssl",
          "pcntl", "pcre", "pdo", "pgsql", "phar", "posix", "pspell", "random",
          "readline", "reflection", "session", "shmop", "simplexml", "snmp", "soap",
          "sockets", "sodium", "spl", "sqlite3", "standard", "superglobals", "sysvmsg",
          "sysvsem", "sysvshm", "tidy", "tokenizer", "xml", "xmlreader", "xmlrpc",
          "xmlwriter", "xsl", "yaml", "zip", "zlib",
        },
        environment = { phpVersion = "8.3" },
        format = { enable = false }, -- handled by conform + php-cs-fixer
        diagnostics = { enable = true },
        completion = { triggerParameterHints = true },
      },
    },
  },

  -- C#
  omnisharp = {
    cmd = { "omnisharp" },
    settings = {
      FormattingOptions = {
        EnableEditorConfigSupport = true,
        OrganizeImports = true,
      },
      MsBuild = { LoadProjectsOnDemand = true },
      RoslynExtensionsOptions = {
        EnableAnalyzersSupport = true,
        EnableImportCompletion = true,
      },
    },
  },

  -- TypeScript / JavaScript (with Vue support via hybrid mode)
  ts_ls = {
    init_options = {
      plugins = {
        {
          name = "@vue/typescript-plugin",
          location = vim.fn.stdpath("data")
            .. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
          languages = { "vue" },
        },
      },
    },
    filetypes = {
      "javascript", "javascriptreact", "javascript.jsx",
      "typescript", "typescriptreact", "typescript.tsx",
      "vue",
    },
    settings = {
      typescript = {
        inlayHints = {
          includeInlayParameterNameHints = "all",
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayVariableTypeHintsWhenTypeMatchesName = false,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
      },
    },
  },

  -- Vue (volar 2.x hybrid mode)
  volar = {
    filetypes = { "vue" },
    init_options = {
      vue = { hybridMode = true },
    },
  },

  -- Lua
  lua_ls = {
    settings = {
      Lua = {
        completion = { callSnippet = "Replace" },
        diagnostics = { disable = { "missing-fields" } },
        telemetry = { enable = false },
        workspace = { checkThirdParty = false },
      },
    },
  },

  -- Markdown
  marksman = {},

  -- Docker
  dockerls = {},
  docker_compose_language_service = {},

  -- SQL
  sqls = {
    settings = {
      sqls = {
        connections = {
          -- Add your database connections here, e.g.:
          -- { driver = "mysql", dataSourceName = "root:@tcp(127.0.0.1:3306)/mydb" },
          -- { driver = "postgresql", dataSourceName = "host=127.0.0.1 port=5432 dbname=mydb sslmode=disable" },
          -- { driver = "sqlite3", dataSourceName = "path/to/my.db" },
        },
      },
    },
  },

  -- Shell
  bashls = {},

  -- Web
  html = {},
  cssls = {},
  jsonls = {
    settings = {
      json = {
        schemas = require("schemastore").json.schemas(),
        validate = { enable = true },
      },
    },
  },
  yamlls = {
    settings = {
      yaml = {
        schemaStore = { enable = false, url = "" },
        schemas = require("schemastore").yaml.schemas(),
      },
    },
  },
}

return {
  -- Mason: LSP/formatter/linter installer
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Open Mason" } },
    build = ":MasonUpdate",
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },

  -- Bridge mason ↔ lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = vim.tbl_keys(servers),
      automatic_installation = true,
    },
  },

  -- Auto-install formatters and linters via mason
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        -- Formatters
        "php-cs-fixer",
        "csharpier",
        "prettierd",
        "stylua",
        "sql-formatter",
        -- Linters
        "phpstan",
        "eslint_d",
        "luacheck",
        "markdownlint-cli2",
        "hadolint",
        "shellcheck",
      },
      auto_update = false,
      run_on_start = true,
    },
  },

  -- LSP configuration
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "b0o/schemastore.nvim",
    },
    config = function()
      -- Diagnostic display
      vim.diagnostic.config({
        underline = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "●",
        },
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.HINT] = " ",
            [vim.diagnostic.severity.INFO] = " ",
          },
        },
      })

      local lspconfig = require("nvim-lspconfig")

      require("mason-lspconfig").setup_handlers({
        function(server_name)
          local config = servers[server_name] or {}
          config.on_attach = on_attach
          config.capabilities = make_capabilities()
          lspconfig[server_name].setup(config)
        end,
      })
    end,
  },

  -- Neovim Lua API completion (replaces neodev)
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "luvit-meta/library", words = { "vim%.uv" } },
      },
    },
  },
  { "Bilal2453/luvit-meta", lazy = true },

  -- JSON/YAML schema store
  { "b0o/schemastore.nvim", lazy = true },
}
