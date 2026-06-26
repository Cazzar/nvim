local opt = vim.opt

opt.number = true
opt.relativenumber = true

opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

opt.wrap = false
opt.linebreak = true

opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.incsearch = true

opt.scrolloff = 8
opt.sidescrolloff = 8
opt.cursorline = true

opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"
opt.colorcolumn = "120"
opt.cmdheight = 1
opt.showtabline = 2
opt.laststatus = 3

opt.hidden = true
opt.errorbells = false
opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undodir"
opt.splitbelow = true
opt.splitright = true
opt.iskeyword:append("-")
opt.clipboard = "unnamedplus"

opt.mouse = ""

opt.completeopt = { "menu", "menuone", "noselect" }
opt.pumheight = 10

-- Treesitter-based folding
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true
opt.foldcolumn = "0"

opt.updatetime = 250
opt.timeoutlen = 300

opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

opt.formatoptions:remove({ "c", "r", "o" })

opt.spelllang = { "en_au" }
opt.spelloptions = "camel"

opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
