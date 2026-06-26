local M = {}

local is_win = vim.fn.has("win32") == 1
local is_mac = vim.fn.has("mac") == 1

local function hint(win, mac, linux)
  if is_win then return win end
  if is_mac then return mac end
  return linux
end

-- { exe, description, critical, install_hint }
local deps = {
  {
    exe      = "tree-sitter",
    desc     = "Treesitter parser compilation",
    critical = true,
    hint     = hint(
      "winget install --id tree-sitter.tree-sitter-cli",
      "brew install tree-sitter",
      "cargo install tree-sitter-cli  (requires clang)"
    ),
  },
  {
    exe      = "git",
    desc     = "Plugin manager (lazy.nvim)",
    critical = true,
    hint     = hint(
      "winget install --id Git.Git",
      "brew install git",
      "sudo apt install git  /  sudo pacman -S git"
    ),
  },
  {
    exe      = "curl",
    desc     = "Mason package downloads",
    critical = true,
    hint     = hint(
      "winget install --id curl.curl",
      "brew install curl",
      "sudo apt install curl  /  sudo pacman -S curl"
    ),
  },
  {
    exe      = "rg",
    desc     = "Telescope live grep",
    critical = true,
    hint     = "mise use -g ripgrep",
  },
  {
    exe      = "fd",
    desc     = "Telescope file search",
    critical = true,
    hint     = "mise use -g fd",
  },
  {
    exe      = "node",
    desc     = "JS/TS/Vue LSP, prettierd, eslint_d",
    critical = false,
    hint     = "mise use -g node@lts",
  },
  {
    exe      = "npm",
    desc     = "Mason: JS-based tool installs",
    critical = false,
    hint     = "Bundled with node — mise use -g node@lts",
  },
  {
    exe      = "php",
    desc     = "PHP LSP (intelephense)",
    critical = false,
    hint     = "mise use -g php",
  },
  {
    exe      = "dotnet",
    desc     = "C# LSP (omnisharp)",
    critical = false,
    hint     = "mise use -g dotnet",
  },
  {
    exe      = "cargo",
    desc     = "Rust toolchain / rust-analyzer",
    critical = false,
    hint     = "Install rustup from https://rustup.rs",
  },
  {
    exe      = "cmake",
    desc     = "telescope-fzf-native build",
    critical = false,
    hint     = hint(
      "winget install --id Kitware.CMake  (required for telescope-fzf-native)",
      "brew install cmake",
      "sudo apt install cmake  /  sudo pacman -S cmake"
    ),
  },
  {
    exe      = "luarocks",
    desc     = "Mason: luacheck linter",
    critical = false,
    hint     = hint(
      "winget install --id DEVCOM.Lua  then: luarocks install luacheck",
      "brew install luarocks  then: luarocks install luacheck",
      "sudo apt install luarocks  then: luarocks install luacheck"
    ),
  },
}

-- Returns { missing_critical, missing_optional } lists
function M.check_deps()
  local critical, optional = {}, {}
  for _, dep in ipairs(deps) do
    if vim.fn.executable(dep.exe) ~= 1 then
      if dep.critical then
        table.insert(critical, dep)
      else
        table.insert(optional, dep)
      end
    end
  end
  return critical, optional
end

-- :checkhealth config
function M.check()
  vim.health.start("External dependencies")

  local missing_critical, missing_optional = M.check_deps()

  if #missing_critical == 0 and #missing_optional == 0 then
    vim.health.ok("All dependencies found")
    return
  end

  for _, dep in ipairs(deps) do
    if vim.fn.executable(dep.exe) == 1 then
      vim.health.ok(string.format("%-14s  %s", dep.exe, dep.desc))
    elseif dep.critical then
      vim.health.error(
        string.format("%-14s  %s", dep.exe, dep.desc),
        { dep.hint }
      )
    else
      vim.health.warn(
        string.format("%-14s  %s", dep.exe, dep.desc),
        { dep.hint }
      )
    end
  end
end

return M
