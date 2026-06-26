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

| Tool | Purpose |
|------|---------|
| `node` + `npm` | JS/TS/Vue LSP, prettierd, eslint_d |
| `dotnet` | C# / OmniSharp LSP |
| `php` | PHP / intelephense LSP |
| `rustup` | Rust — install via [rustup.rs](https://rustup.rs), not mise |
| `fd` | Telescope file search |
| `ripgrep` | Telescope live grep |
| `cmake` | fzf-native build (Windows: `scoop install cmake`) |
| `luarocks` | Mason: luacheck — see below |

### LuaRocks / luacheck (Windows)

Mason installs `luacheck` via LuaRocks. On Windows with MSYS2 (ucrt64):

```bash
pacman -S mingw-w64-ucrt-x86_64-luarocks
luarocks install luacheck
```

Or via Scoop:

```powershell
scoop install luarocks
luarocks install luacheck
```

After installing luarocks, reopen Neovim and run `:MasonToolsInstall` — luacheck will install cleanly.

## Tmux integration

Add to `~/.tmux.conf`:

```tmux
set -g @plugin 'christoomey/vim-tmux-navigator'
run '~/.tmux/plugins/tpm/tpm'
```

## SQL connections

Add database connection strings to `lua/plugins/sql.lua` in the `sqls` server settings,
or use `:DBUIAddConnection` at runtime to add them interactively.

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
