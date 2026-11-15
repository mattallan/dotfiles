vim.pack.add({
  { src = "https://github.com/nvim-neo-tree/neo-tree.nvim", version = vim.version.range("3") },
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/MunifTanjim/nui.nvim",
  "https://github.com/nvim-tree/nvim-web-devicons",
})

-- From a Telescope prompt, close the picker first: otherwise its BufLeave handler closes
-- windows while the float is taking focus, and Neovim raises E1312.
vim.keymap.set("n", "<leader>e", function()
  if vim.bo.filetype == "TelescopePrompt" then
    require("telescope.actions").close(vim.api.nvim_get_current_buf())
  end
  vim.cmd("Neotree float filesystem reveal toggle")
end, {
  desc = "Explorer",
})

require("neo-tree").setup({
  close_if_last_window = true,
  enable_git_status = true,
  enable_diagnostics = true,

  popup_border_style = "rounded",

  event_handlers = {
    {
      event = "file_opened",
      handler = function()
        require("neo-tree.command").execute({ action = "close" })
      end,
    },
    {
      event = "neo_tree_buffer_enter",
      handler = function()
        if vim.b.neo_tree_help_shown then return end
        vim.b.neo_tree_help_shown = true
        vim.schedule(function()
          require("neo-tree.command").execute({ action = "show_help" })
        end)
      end,
    },
  },

  window = {
    position = "float",
    width = 60,
    mappings = {
      ["<space>"] = "none",
    },
    popup = {
      size = {
        width = 60,
        height = "80%",
      },
      position = "50%",
      border = {
        style = "rounded",
      },
    },
  },

  default_component_configs = {
    container = {
      enable_character_fade = true,
    },

    indent = {
      indent_size = 2,
      padding = 1,
      with_markers = true,
      indent_marker = "│",
      last_indent_marker = "└",
      highlight = "NeoTreeIndentMarker",
      with_expanders = true,
      expander_collapsed = "",
      expander_expanded = "",
      expander_highlight = "NeoTreeExpander",
    },

    icon = {
      folder_closed = "",
      folder_open = "",
      folder_empty = "󰜌",
      default = "*",
      highlight = "NeoTreeFileIcon",
    },

    modified = {
      symbol = "[+]",
      highlight = "NeoTreeModified",
    },

    git_status = {
      symbols = {
        added     = "",
        modified  = "",
        deleted   = "✖",
        renamed   = "󰁕",
        untracked = "",
        ignored   = "",
        unstaged  = "󰄱",
        staged    = "",
        conflict  = "",
      },
    },

    name = {
      trailing_slash = false,
      use_git_status_colors = true,
      highlight = "NeoTreeFileName",
    },

    diagnostics = {
      symbols = {
        hint  = "",
        info  = "",
        warn  = "",
        error = "",
      },
      highlights = {
        hint  = "DiagnosticHint",
        info  = "DiagnosticInfo",
        warn  = "DiagnosticWarn",
        error = "DiagnosticError",
      },
    },
  },

  filesystem = {
    filtered_items = {
      visible = true,
      hide_dotfiles = false,
      hide_gitignored = false,
    },

    follow_current_file = {
      enabled = true,
    },

    -- Search (/ and f) skips the heavy dirs: with gitignored files shown, it otherwise walks
    -- all of tc-portal's vendor, node_modules and worktrees and takes many seconds. Browsing still shows them.
    find_args = function(cmd, _, _, args)
      local skipped = { ".git", "node_modules", "vendor", "worktrees" }
      if cmd == "fd" or cmd == "fdfind" then
        for _, dir in ipairs(skipped) do
          table.insert(args, "--exclude")
          table.insert(args, dir)
        end
        return args
      end
      if cmd ~= "find" then
        return args
      end

      -- find takes the path first, so the prune goes straight after it.
      local prune = { "(" }
      for i, dir in ipairs(skipped) do
        if i > 1 then
          table.insert(prune, "-o")
        end
        vim.list_extend(prune, { "-name", dir })
      end
      vim.list_extend(prune, { ")", "-prune", "-o" })
      return vim.list_extend({ args[1] }, vim.list_extend(prune, vim.list_slice(args, 2)))
    end,

    use_libuv_file_watcher = true,
    hijack_netrw_behavior = "open_default",

    window = {
      mappings = {
        ["l"] = "open",
        ["h"] = "close_node",
        ["<cr>"] = "open",
        ["o"] = "open",
      },
    },
  },
})
