local function is_sha(s) return s:match("^%x%x%x%x%x%x%x") ~= nil end

-- Detect the merge-base of HEAD against the remote default branch.
-- Returns the commit SHA, or nil if it can't be determined.
local function get_pr_base()
  local remote_head = vim.fn.system({ "git", "rev-parse", "--abbrev-ref", "origin/HEAD" }):gsub("%s+", "")
  local base_ref
  if remote_head ~= "" and not remote_head:match("^fatal") and not remote_head:match("^error") then
    base_ref = remote_head
  else
    for _, ref in ipairs({ "origin/main", "origin/master", "origin/develop" }) do
      local result = vim.fn.system({ "git", "rev-parse", "--verify", ref }):gsub("%s+", "")
      if is_sha(result) then
        base_ref = ref
        break
      end
    end
  end
  if not base_ref then return nil end
  local sha = vim.fn.system({ "git", "merge-base", base_ref, "HEAD" }):gsub("%s+", "")
  return is_sha(sha) and sha or nil
end

-- Tab-completion for git refs, wired into vim.fn.input via customlist.
_G._pr_base_complete = function(arglead)
  local refs = vim.fn.systemlist({ "git", "for-each-ref", "--format=%(refname:short)", "refs/remotes", "refs/heads" })
  refs = vim.tbl_filter(function(r) return r ~= "" and not r:match("^fatal") end, refs)
  if arglead == "" then return refs end
  return vim.tbl_filter(function(r) return r:find(arglead, 1, true) ~= nil end, refs)
end

-- Compute merge-base against an explicit ref (no auto-detection).
local function pr_base_for(ref)
  local sha = vim.fn.system({ "git", "merge-base", ref, "HEAD" }):gsub("%s+", "")
  return is_sha(sha) and sha or nil
end

local pr_mode = false

return {
  -- Git signs in the gutter
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add          = { text = "▎" },
        change       = { text = "▒" },
        delete       = { text = "" },
        topdelete    = { text = "" },
        changedelete = { text = "▒" },
        untracked    = { text = "┆" },
      },
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local map = function(mode, keys, func, desc)
          vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = "Git: " .. desc })
        end

        -- Navigation
        map("n", "]h", function() gs.nav_hunk("next") end, "Next hunk")
        map("n", "[h", function() gs.nav_hunk("prev") end, "Prev hunk")
        map("n", "]H", function() gs.nav_hunk("last") end, "Last hunk")
        map("n", "[H", function() gs.nav_hunk("first") end, "First hunk")

        -- Staging
        map({ "n", "v" }, "<leader>ghs", gs.stage_hunk, "Stage hunk")
        map({ "n", "v" }, "<leader>ghr", gs.reset_hunk, "Reset hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage buffer")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo stage hunk")

        -- Inspection
        map("n", "<leader>ghp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame line")
        map("n", "<leader>ghB", gs.blame, "Blame buffer")
        map("n", "<leader>ghd", gs.diffthis, "Diff this")
        map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff this ~")

        -- PR diff mode: toggle gutter signs against merge-base instead of HEAD
        map("n", "<leader>gp", function()
          if pr_mode then
            gs.reset_base(true)
            pr_mode = false
            vim.notify("Gitsigns: local diff mode", vim.log.levels.INFO)
          else
            local base = get_pr_base()
            if base then
              gs.change_base(base, true)
              pr_mode = true
              vim.notify("Gitsigns: PR diff mode (" .. base:sub(1, 8) .. ")", vim.log.levels.INFO)
            else
              vim.notify("Gitsigns: could not determine PR base", vim.log.levels.WARN)
            end
          end
        end, "Toggle PR diff mode")

        map("n", "<leader>gpb", function()
          local ref = vim.fn.input({ prompt = "PR base ref: ", completion = "customlist,v:lua._pr_base_complete" })
          if not ref or ref == "" then return end
          local base = pr_base_for(ref)
          if base then
            gs.change_base(base, true)
            pr_mode = true
            vim.notify("Gitsigns: PR diff mode (" .. ref .. " @ " .. base:sub(1, 8) .. ")", vim.log.levels.INFO)
          else
            vim.notify("Gitsigns: could not find merge-base with " .. ref, vim.log.levels.WARN)
          end
        end, "PR diff mode (custom base)")

        -- Text object
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select hunk")
      end,
    },
  },

  -- Magit-style Git UI
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    cmd = "Neogit",
    keys = {
      { "<leader>gg", "<cmd>Neogit<cr>", desc = "Neogit" },
      { "<leader>gG", function() require("neogit").open({ cwd = vim.fn.expand("%:p:h") }) end, desc = "Neogit (file dir)" },
    },
    opts = {
      integrations = {
        diffview = true,
        telescope = true,
      },
      remember_settings = true,
      use_per_project_settings = true,
      signs = {
        hunk = { "", "" },
        item = { ">", "v" },
        section = { ">", "v" },
      },
    },
  },

  -- Diff viewer & merge tool
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "DiffView open" },
      { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "DiffView close" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Repo history" },
      { "<leader>gP", function()
        local base = get_pr_base()
        if base then
          vim.cmd("DiffviewOpen " .. base .. "...HEAD -- " .. vim.fn.fnameescape(vim.fn.getcwd()))
        else
          vim.notify("Could not determine PR base", vim.log.levels.WARN)
        end
      end, desc = "PR file changes (DiffView)" },
      { "<leader>gPb", function()
        local ref = vim.fn.input({ prompt = "PR base ref: ", completion = "customlist,v:lua._pr_base_complete" })
        if not ref or ref == "" then return end
        local base = pr_base_for(ref)
        if base then
          vim.cmd("DiffviewOpen " .. base .. "...HEAD -- " .. vim.fn.fnameescape(vim.fn.getcwd()))
        else
          vim.notify("Could not find merge-base with " .. ref, vim.log.levels.WARN)
        end
      end, desc = "PR file changes — custom base (DiffView)" },
    },
    opts = {
      enhanced_diff_hl = true,
      hooks = {
        diff_buf_read = function(bufnr)
          vim.opt_local.wrap = false
          vim.opt_local.list = false
          vim.opt_local.relativenumber = false
        end,
      },
    },
  },

  -- Classic Fugitive (for :GBrowse, :Git blame, etc.)
  {
    "tpope/vim-fugitive",
    dependencies = { "tpope/vim-rhubarb" },
    cmd = { "Git", "GBrowse", "Gdiffsplit", "Gread", "Gwrite", "Gclog" },
    keys = {
      { "<leader>gf", "<cmd>Git<cr>", desc = "Fugitive" },
      { "<leader>gB", "<cmd>GBrowse<cr>", desc = "Browse on remote" },
    },
  },
}
