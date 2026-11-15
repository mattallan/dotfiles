vim.pack.add({ 'https://github.com/folke/todo-comments.nvim' })

require('todo-comments').setup({
  signs = false,
})

local map = function(lhs, rhs, desc)
  vim.keymap.set('n', lhs, rhs, { desc = desc })
end

map(']t', function() require('todo-comments').jump_next() end, 'Next todo comment')
map('[t', function() require('todo-comments').jump_prev() end, 'Previous todo comment')
map('<leader>st', '<cmd>TodoTelescope<cr>', 'Search todos')
map('<leader>xt', '<cmd>Trouble todo toggle<cr>', 'Todos (Trouble)')
