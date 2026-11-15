vim.pack.add({
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1") },
})

require('blink.cmp').setup({
  keymap = { preset = 'default' },

  appearance = {
    nerd_font_variant = 'mono',
  },

  completion = {
    documentation = { auto_show = true, auto_show_delay_ms = 200 },
  },

  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
  },

  snippets = { preset = 'default' },

  fuzzy = { implementation = 'prefer_rust_with_warning' },

  signature = { enabled = true },
})

vim.lsp.config('*', {
  -- Disable LSP dynamic file watching. Neovim implements didChangeWatchedFiles
  -- by walking the workspace root, which for tc-portal is ~340k files (multiple
  -- node_modules + nested .claude/worktrees). Server-side `files.exclude`
  -- settings do NOT filter this walk, so it stalls the first file open and burns
  -- CPU on changes. Servers keep their own internal watchers, so LSP still works.
  capabilities = require('blink.cmp').get_lsp_capabilities({
    workspace = {
      didChangeWatchedFiles = {
        dynamicRegistration = false,
      },
    },
  }),
})
