-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Set leader before loading plugins
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local pre_init = vim.fn.stdpath("config") .. "/pre-init.local.lua"
if vim.loop.fs_stat(pre_init) then
  dofile(pre_init)
end

require("config.options")
require("config.keymaps")
require("config.autocmds")

local specs = { { import = "plugins" } }
if vim.loop.fs_stat(vim.fn.stdpath("config") .. "/lua/local") then
  table.insert(specs, { import = "local" })
end

require("lazy").setup(specs, {
  change_detection = { notify = false },
  checker = { enabled = true, notify = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "matchit", "matchparen", "netrwPlugin",
        "tarPlugin", "tohtml", "tutor", "zipPlugin",
      },
    },
  },
})

local post_init = vim.fn.stdpath("config") .. "/post-init.local.lua"
if vim.loop.fs_stat(post_init) then
  dofile(post_init)
end
