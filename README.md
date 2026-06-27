# Neovim Config

Personal Neovim config built on [lazy.nvim](https://github.com/folke/lazy.nvim).  
Requires **Neovim 0.12+**.

## Quick start

```
# Windows
git clone <repo> %LOCALAPPDATA%\nvim

# Linux / macOS
git clone <repo> ~/.config/nvim
```

Open Neovim — lazy.nvim will bootstrap itself and install all plugins automatically.  
Run `:Lazy sync` if anything is missing, then `:Mason` to confirm LSP servers and tools.

## System requirements

[mise](https://mise.jdx.dev) is assumed on all environments. Mason installs LSP servers
and formatters automatically, but the tools below are prerequisites.

Add a global `~/.config/mise/config.toml` (or per-project `.mise.toml`) with at minimum:

```toml
[tools]
node    = "lts"
python  = "latest"
php     = "latest"
dotnet  = "latest"
fd      = "latest"
ripgrep = "latest"
```

Then `mise install` to pull everything down.

### tree-sitter-cli

Required by the new nvim-treesitter (0.12 rewrite) to compile parsers locally.

```powershell
# Windows
winget install --id tree-sitter.tree-sitter-cli

# macOS
brew install tree-sitter

# Linux
cargo install tree-sitter-cli
# (requires clang — e.g. apt install clang / pacman -S clang)
```

After installing, open Neovim and run `:TSUpdate`.

### Nerd Font

Required for file-type icons in the explorer, statusline, and bufferline.
[JetBrainsMono Nerd Font](https://www.nerdfonts.com/font-downloads) is a good default.

```powershell
# Windows
winget install -e --id DEVCOM.JetBrainsMonoNerdFont
```

```bash
# macOS
brew install --cask font-jetbrains-mono-nerd-font
```

After installing, set the font in your terminal.
If you skip the font install, set `vim.g.have_nerd_font = false` in `pre-init.local.lua` — icons will fall back to plain ASCII.

- **Windows Terminal** — Settings → the profile you use → Appearance → Font face → `JetBrainsMono Nerd Font`
- **Ghostty** — add to `~/.config/ghostty/config`:
  ```
  font-family = JetBrainsMono Nerd Font
  ```

| Tool | Purpose |
|------|---------|
| `tree-sitter` | **Required** — compile treesitter parsers (see below) |
| `node` + `npm` | JS/TS/Vue LSP, prettierd, eslint_d |
| `dotnet` | C# / OmniSharp LSP |
| `php` | PHP / intelephense LSP |
| `rustup` | Rust — install via [rustup.rs](https://rustup.rs), not mise |
| `fd` | Telescope file search (`mise use -g fd`) |
| `ripgrep` | Telescope live grep (`mise use -g ripgrep`) |
| `cmake` | telescope-fzf-native build — `winget install --id Kitware.CMake` |
| `luarocks` | Mason: luacheck — see below |

### LuaRocks / luacheck (Windows)

Mason installs `luacheck` via LuaRocks.

```powershell
winget install --id DEVCOM.Lua
luarocks install luacheck
```

After installing, reopen Neovim and run `:MasonToolsInstall` — luacheck will install cleanly.

## Tmux integration

Add to `~/.tmux.conf`:

```tmux
set -g @plugin 'christoomey/vim-tmux-navigator'
run '~/.tmux/plugins/tpm/tpm'
```

## Machine-local config

Three escape hatches that are gitignored and never committed:

| File / Path | When it loads | Use for |
|---|---|---|
| `pre-init.local.lua` | Before options, keymaps, and plugins | Leader key override, early globals |
| `post-init.local.lua` | After all plugins are loaded | Extra keymaps, plugin overrides, machine-specific config |
| `lua/local/*.lua` | During lazy.nvim setup | Adding plugins or overriding plugin specs locally |

`lua/local/` only needs to exist when you actually have local plugins — create it on demand.
`pre-init.local.lua` and `post-init.local.lua` are silently skipped if absent.

Example — override the leader key on one machine:

```lua
-- pre-init.local.lua
vim.g.mapleader = ","
```

## Per-project config (`.nvim.lua`)

`exrc` is enabled, so Neovim reads `.nvim.lua` from the project root on startup (Neovim will prompt to trust the file the first time). Use this to override formatting, LSP settings, or anything else per repo.

Common uses:

```lua
-- .nvim.lua — disable format-on-save for this repo
require("conform").setup({ format_on_save = false })
```

```lua
-- .nvim.lua — use a different formatter for this repo
require("conform").setup({
  formatters_by_ft = { cs = { "csharpier" } },
})
```

You can commit `.nvim.lua` to the repo so the whole team gets the same behaviour.

## SQL connections

Connections are machine-local and never committed. Two options:

- **Interactive:** `:DBUIAddConnection` — saved automatically to `stdpath("data")` outside the repo.
- **Pre-configured:** define `vim.g.dbs` in `post-init.local.lua`:

```lua
-- post-init.local.lua
vim.g.dbs = {
  { name = "work-pg",  url = "postgresql://user:pass@host/db" },
  { name = "local-pg", url = "postgresql://localhost/mydb" },
}
```

## Key mappings (highlights)

| Key | Action |
|-----|--------|
| `<Space>` | Leader |
| `s` | Flash jump (EasyMotion-style) |
| `S` | Flash treesitter jump |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `<leader>gg` | Neogit |
| `<leader>e` | File explorer |
| `<leader>xx` | Diagnostics (Trouble) |
| `<leader>Du` | DB UI |
| `gd` | Go to definition |
| `gr` | Go to references |
| `K` | Hover docs |
| `<leader>cr` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>cf` | Format buffer |
