vim.pack.add({ 'https://github.com/rachartier/tiny-inline-diagnostic.nvim' })

require('tiny-inline-diagnostic').setup({
  preset = 'modern',
  options = {
    show_source = { enabled = true, if_many = true },
    multilines = { enabled = true, always_show = false },
    show_all_diags_on_cursorline = false,
    enable_on_insert = false,
  },
})
