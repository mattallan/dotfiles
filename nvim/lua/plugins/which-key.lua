vim.pack.add({'https://github.com/folke/which-key.nvim'})

require("which-key").setup({
  icons = {
    mappings = false,
    rules = false,
  },
})

require("which-key").add({
    { "<leader>s", group = "Search" },
    { "<leader>g", group = "Git" },
    { "<leader>c", group = "Code" },
    { "<leader>q", group = "Session" },
    { "<leader>t", group = "Toggle" },
    { "<leader>x", group = "Diagnostics" },
    { "<leader>n", group = "Notifications" },
})
