-- lua/plugins/treesitter.lua
vim.pack.add({
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
})

local ts = require("nvim-treesitter")

ts.setup({
  install_dir = vim.fn.stdpath("data") .. "/site",
})

-- Parser names, which are not always the filetype name (ft typescriptreact ->
-- tsx, ft jsonc -> json). `vim.treesitter.language.get_lang` does that mapping
-- for us at start() time, so only the parser names belong in this list.
ts.install({
  "bash",
  "blade",
  "css",
  "diff",
  "dockerfile",
  "gitcommit",
  "html",
  "javascript",
  "json",
  "lua",
  "markdown",
  "markdown_inline",
  "php",
  "query",
  "regex",
  "scss",
  "sql",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "vue",
  "xml",
  "yaml",
})

-- Start treesitter for every buffer that has a parser installed. Deliberately
-- not a `pattern` list: parser names and filetype names disagree often enough
-- that keeping two lists in sync is its own bug source. `start` throws when
-- there's no parser for the filetype (neo-tree, noice, help, ...), and that
-- miss costs well under a millisecond, once per buffer — so swallow it and let
-- those buffers keep the regex syntax engine.
vim.api.nvim_create_autocmd("FileType", {
  callback = function(event)
    pcall(vim.treesitter.start, event.buf)
  end,
})
