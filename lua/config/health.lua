local M = {}

-- { exe, description, critical, install_hint }
local deps = {
  {
    exe = "tree-sitter",
    desc = "Treesitter parser compilation",
    critical = true,
    hint = "cargo install tree-sitter-cli  (or: mise use cargo:tree-sitter-cli)",
  },
  {
    exe = "git",
    desc = "Plugin manager (lazy.nvim)",
    critical = true,
    hint = "Install via your system package manager",
  },
  {
    exe = "curl",
    desc = "Mason package downloads",
    critical = true,
    hint = "Install via your system package manager",
  },
  {
    exe = "rg",
    desc = "Telescope live grep",
    critical = true,
    hint = "mise use ripgrep  (or: scoop install ripgrep)",
  },
  {
    exe = "fd",
    desc = "Telescope file search",
    critical = true,
    hint = "mise use fd  (or: scoop install fd)",
  },
  {
    exe = "node",
    desc = "JS/TS/Vue LSP, prettierd, eslint_d",
    critical = false,
    hint = "mise use node@lts",
  },
  {
    exe = "npm",
    desc = "Mason: JS-based tool installs",
    critical = false,
    hint = "Bundled with node — mise use node@lts",
  },
  {
    exe = "php",
    desc = "PHP LSP (intelephense)",
    critical = false,
    hint = "mise use php",
  },
  {
    exe = "dotnet",
    desc = "C# LSP (omnisharp)",
    critical = false,
    hint = "mise use dotnet",
  },
  {
    exe = "cargo",
    desc = "Rust toolchain / rust-analyzer",
    critical = false,
    hint = "Install rustup from https://rustup.rs",
  },
  {
    exe = "cmake",
    desc = "telescope-fzf-native build",
    critical = false,
    hint = "scoop install cmake  (or: mise use cmake)",
  },
  {
    exe = "luarocks",
    desc = "Mason: luacheck linter",
    critical = false,
    hint = "pacman -S mingw-w64-ucrt-x86_64-luarocks  (or: scoop install luarocks)",
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
