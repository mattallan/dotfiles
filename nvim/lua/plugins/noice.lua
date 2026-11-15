vim.pack.add({
  'https://github.com/folke/noice.nvim',
  'https://github.com/rcarriga/nvim-notify',
})

require('notify').setup({
  background_colour = '#000000',
  render = 'compact',
  stages = 'fade',
  timeout = 2500,
})

require('noice').setup({
  -- Classic bottom-row cmdline instead of the centred popup.
  cmdline = {
    view = 'cmdline',
  },
  lsp = {
    override = {
      ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
      ['vim.lsp.util.stylize_markdown'] = true,
    },
  },
  presets = {
    bottom_search = true,
    long_message_to_split = true,
    lsp_doc_border = true,
  },
  routes = {
    {
      filter = { event = 'msg_show', kind = '', find = 'written' },
      opts = { skip = true },
    },
  },
})

vim.keymap.set('n', '<leader>nd', function() require('notify').dismiss({ silent = true }) end, { desc = 'Dismiss notifications' })
vim.keymap.set('n', '<leader>nh', '<cmd>NoiceHistory<cr>', { desc = 'Noice history' })
