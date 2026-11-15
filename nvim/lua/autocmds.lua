-- Open PHP files with the cursor on the class declaration. Explicit jumps
-- (LSP definition, telescope results, `nvim +42`) set the cursor afterwards,
-- so they still win.
vim.api.nvim_create_autocmd('BufReadPost', {
  group = vim.api.nvim_create_augroup('mattallan-cursor-on-class', { clear = true }),
  pattern = '*.php',
  callback = function()
    local pos = vim.fn.searchpos([[\v(^\s*((abstract|final|readonly)\s+)*|<new\s+)\zsclass>]], 'cnw')
    if pos[1] == 0 then
      return
    end

    vim.api.nvim_win_set_cursor(0, { pos[1], pos[2] - 1 })
  end,
})
