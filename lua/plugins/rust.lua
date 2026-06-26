return {
  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    lazy = false, -- must load eagerly so it can set up rust-analyzer
    ft = { "rust" },
    opts = {
      server = {
        on_attach = function(_, bufnr)
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "Rust: " .. desc })
          end
          map("K", function() vim.cmd.RustLsp("hover", "actions") end, "Hover actions")
          map("<leader>cA", function() vim.cmd.RustLsp("codeAction") end, "Code action")
          map("<leader>ca", function() vim.cmd.RustLsp("hover", "actions") end, "Hover actions")
          map("<leader>re", function() vim.cmd.RustLsp("expandMacro") end, "Expand macro")
          map("<leader>rR", function() vim.cmd.RustLsp("runnables") end, "Runnables")
          map("<leader>rt", function() vim.cmd.RustLsp("testables") end, "Testables")
          map("<leader>rd", function() vim.cmd.RustLsp("debuggables") end, "Debuggables")
          map("<leader>rp", function() vim.cmd.RustLsp("parentModule") end, "Parent module")
          map("<leader>rj", function() vim.cmd.RustLsp("joinLines") end, "Join lines")
          map("<leader>ro", function() vim.cmd.RustLsp("openDocs") end, "Open docs.rs")
          map("<leader>rr", function() vim.cmd.RustLsp("relatedDiagnostics") end, "Related diagnostics")
          map("<leader>rg", function() vim.cmd.RustLsp("crateGraph") end, "Crate graph")
          -- LSP standard keymaps
          map("gd", function() require("telescope.builtin").lsp_definitions() end, "Go to definition")
          map("gr", function() require("telescope.builtin").lsp_references() end, "Go to references")
          map("<leader>cr", vim.lsp.buf.rename, "Rename")
          map("[d", vim.diagnostic.goto_prev, "Prev diagnostic")
          map("]d", vim.diagnostic.goto_next, "Next diagnostic")
        end,
        default_settings = {
          ["rust-analyzer"] = {
            cargo = {
              allFeatures = true,
              loadOutDirsFromCheck = true,
              runBuildScripts = true,
            },
            checkOnSave = {
              allFeatures = true,
              command = "clippy",
              extraArgs = { "--no-deps" },
            },
            procMacro = {
              enable = true,
              ignored = {
                ["async-trait"] = { "async_trait" },
                ["napi-derive"] = { "napi" },
                ["async-recursion"] = { "async_recursion" },
              },
            },
            inlayHints = {
              bindingModeHints = { enable = false },
              chainingHints = { enable = true },
              closingBraceHints = { enable = true, minLines = 25 },
              closureReturnTypeHints = { enable = "never" },
              lifetimeElisionHints = { enable = "never", useParameterNames = false },
              maxLength = { enable = true, maxLength = 25 },
              parameterHints = { enable = true },
              reborrowHints = { enable = "never" },
              renderColons = { enable = true },
              typeHints = {
                enable = true,
                hideClosureInitialization = false,
                hideNamedConstructor = false,
              },
            },
          },
        },
      },
    },
    config = function(_, opts)
      vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts or {})
    end,
  },

  -- Cargo.toml dependency management
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    opts = {
      completion = {
        cmp = { enabled = true },
      },
    },
    config = function(_, opts)
      require("crates").setup(opts)
      vim.api.nvim_create_autocmd("BufRead", {
        group = vim.api.nvim_create_augroup("crates_buf_read", { clear = true }),
        pattern = "Cargo.toml",
        callback = function()
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = true, desc = "Crates: " .. desc })
          end
          local crates = require("crates")
          map("<leader>ct", crates.toggle, "Toggle")
          map("<leader>cr", crates.reload, "Reload")
          map("<leader>cv", crates.show_versions_popup, "Versions")
          map("<leader>cf", crates.show_features_popup, "Features")
          map("<leader>cd", crates.show_dependencies_popup, "Dependencies")
          map("<leader>cu", crates.update_crate, "Update crate")
          map("<leader>cU", crates.update_all_crates, "Update all")
          map("<leader>cg", crates.upgrade_crate, "Upgrade crate")
          map("<leader>cG", crates.upgrade_all_crates, "Upgrade all")
        end,
      })
    end,
  },
}
