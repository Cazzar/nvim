return {
  -- Flash: EasyMotion/Hop successor with treesitter awareness
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        char = {
          -- f/F/t/T enhanced with jump labels
          enabled = true,
          jump_labels = true,
          multi_line = false,
          label = { exclude = "hjkliardc" },
          keys = { "f", "F", "t", "T", ";", "," },
          highlight = { backdrop = false },
        },
        search = {
          -- Flash works within / and ? searches
          enabled = true,
        },
      },
      label = {
        uppercase = false,
        rainbow = { enabled = false },
      },
    },
    keys = {
      -- s to jump to any word on screen
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash jump" },
      -- S for treesitter-aware selection
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash treesitter" },
      -- r for remote flash in operator-pending (e.g. yr<flash>)
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote flash" },
      -- R for treesitter in operator-pending
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Flash treesitter search" },
      -- toggle flash in / search
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle flash search" },
    },
  },
}
