local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

autocmd("TextYankPost", {
  group = augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

autocmd("BufReadPost", {
  group = augroup("restore_cursor", { clear = true }),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

autocmd("BufWritePre", {
  group = augroup("trim_whitespace", { clear = true }),
  pattern = "*",
  callback = function()
    local save = vim.fn.winsaveview()
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.winrestview(save)
  end,
})

-- Close auxiliary windows with q
autocmd("FileType", {
  group = augroup("close_with_q", { clear = true }),
  pattern = {
    "help", "lspinfo", "man", "notify", "qf",
    "startuptime", "checkhealth", "gitsigns.blame",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Load mise environment on startup
autocmd("VimEnter", {
  group = augroup("mise_env", { clear = true }),
  once = true,
  callback = function()
    local mise_bin = vim.fn.exepath("mise")
    if mise_bin == "" then
      -- try common install path
      local home = vim.fn.expand("~")
      local candidate = home .. "/.local/bin/mise"
      if vim.fn.executable(candidate) == 1 then
        mise_bin = candidate
      end
    end
    if mise_bin == "" then return end
    local handle = io.popen(mise_bin .. " env --shell bash 2>/dev/null")
    if not handle then return end
    local result = handle:read("*a")
    handle:close()
    for key, value in result:gmatch('export ([%w_]+)="?([^"\n]+)"?\n') do
      if key == "PATH" then
        vim.env.PATH = value
      else
        vim.env[key] = value
      end
    end
  end,
})

-- .env file detection
autocmd({ "BufRead", "BufNewFile" }, {
  group = augroup("env_filetype", { clear = true }),
  pattern = { ".env", ".env.*", "*.env" },
  callback = function()
    vim.bo.filetype = "sh"
  end,
})

autocmd("VimResized", {
  group = augroup("resize_splits", { clear = true }),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- Spell + wrap in prose filetypes
autocmd("FileType", {
  group = augroup("wrap_spell", { clear = true }),
  pattern = { "gitcommit", "markdown", "text" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- PHP: 4-space indent
autocmd("FileType", {
  group = augroup("php_indent", { clear = true }),
  pattern = "php",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
  end,
})

-- SQL: 4-space indent
autocmd("FileType", {
  group = augroup("sql_indent", { clear = true }),
  pattern = { "sql", "mysql", "plsql" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
  end,
})
