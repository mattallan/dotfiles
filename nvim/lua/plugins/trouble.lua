vim.pack.add({ 'https://github.com/folke/trouble.nvim' })

require('trouble').setup({})

local map = function(lhs, rhs, desc)
  vim.keymap.set('n', lhs, rhs, { desc = desc })
end

map('<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', 'Diagnostics (Trouble)')
map('<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', 'Buffer Diagnostics')
map('<leader>xs', '<cmd>Trouble symbols toggle focus=false<cr>', 'Symbols')
map('<leader>xl', '<cmd>Trouble lsp toggle focus=false win.position=right<cr>', 'LSP Definitions / References')
map('<leader>xL', '<cmd>Trouble loclist toggle<cr>', 'Location List')
map('<leader>xQ', '<cmd>Trouble qflist toggle<cr>', 'Quickfix List')
