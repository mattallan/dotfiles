vim.pack.add({ 'https://github.com/stevearc/conform.nvim' })

local conform = require('conform')

conform.setup({
  formatters_by_ft = {
    php = { 'pint' },
    blade = { 'prettier' },
    lua = { 'stylua' },
    javascript = { 'prettier' },
    javascriptreact = { 'prettier' },
    typescript = { 'prettier' },
    typescriptreact = { 'prettier' },
    vue = { 'prettier' },
    css = { 'prettier' },
    scss = { 'prettier' },
    html = { 'prettier' },
    json = { 'prettier' },
    jsonc = { 'prettier' },
    yaml = { 'prettier' },
    markdown = { 'prettier' },
  },

  format_on_save = function(bufnr)
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return
    end
    return { timeout_ms = 2000, lsp_format = 'fallback' }
  end,
})

conform.formatters.prettier = {
  inherit = true,
  prefer_local = 'node_modules/.bin',
}

conform.formatters.pint = {
  inherit = true,
  prefer_local = 'vendor/bin',
}

vim.api.nvim_create_user_command('FormatDisable', function(args)
  if args.bang then
    vim.b.disable_autoformat = true
  else
    vim.g.disable_autoformat = true
  end
end, { desc = 'Disable autoformat (use ! for buffer-local)', bang = true })

vim.api.nvim_create_user_command('FormatEnable', function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end, { desc = 'Re-enable autoformat' })

vim.keymap.set({ 'n', 'v' }, '<leader>cf', function()
  conform.format({ async = true, lsp_format = 'fallback' })
end, { desc = 'Format buffer/selection' })
