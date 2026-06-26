return {
  -- Mise version manager integration
  -- Activates per-directory tool versions from .mise.toml / .tool-versions
  {
    "jdx/mise.nvim",
    lazy = false,
    opts = {},
    config = function(_, opts)
      require("mise").setup(opts)
    end,
    -- Fallback: if mise.nvim isn't available or has issues,
    -- autocmds.lua already handles loading the mise env at VimEnter.
  },
}
