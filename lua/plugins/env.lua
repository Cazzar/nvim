return {
  -- Cloak .env values so they don't show on screen (screen sharing safe)
  {
    "laytan/cloak.nvim",
    event = { "BufReadPre", "BufNewFile" },
    keys = {
      { "<leader>uc", "<cmd>CloakToggle<cr>", desc = "Toggle cloak (.env)" },
    },
    opts = {
      enabled = true,
      cloak_character = "*",
      highlight_group = "Comment",
      patterns = {
        {
          file_pattern = {
            ".env",
            ".env.*",
            "*.env",
            "wrangler.toml",
            "wrangler.*.toml",
          },
          cloak_pattern = "=.+",
          replace = nil,
        },
      },
    },
  },
  -- .env files are detected as 'sh' filetype (see autocmds.lua), so the
  -- bash/sh treesitter grammar handles KEY=value syntax highlighting.
  -- CloakToggle masks the values for screen sharing safety.
}
