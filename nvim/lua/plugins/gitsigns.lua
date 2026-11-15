vim.pack.add({ 'https://github.com/lewis6991/gitsigns.nvim' })

require('gitsigns').setup({
  current_line_blame = true,
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol',
    delay = 500,
    ignore_whitespace = false,
  },
  current_line_blame_formatter = '<author>, <author_time:%R> · <summary>',
  on_attach = function(bufnr)
    local gs = require('gitsigns')

    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end

    map('n', ']c', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, 'Next hunk')

    map('n', '[c', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, 'Previous hunk')

    map('n', '<leader>gr', gs.reset_hunk, 'Reset hunk')
    map('v', '<leader>gr', function() gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, 'Reset hunk')
    map('n', '<leader>gR', gs.reset_buffer, 'Reset buffer')
    map('n', '<leader>gp', gs.preview_hunk, 'Preview hunk')
    map('n', '<leader>gb', gs.toggle_current_line_blame, 'Toggle line blame')
    map('n', '<leader>gB', function() gs.blame_line({ full = true }) end, 'Blame line (popup)')
    map('n', '<leader>gd', gs.diffthis, 'Diff this')
    map('n', '<leader>gD', function() gs.diffthis('~') end, 'Diff this ~')
    map('n', '<leader>gt', gs.toggle_deleted, 'Toggle deleted')

    map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', 'Select hunk')
  end,
})
