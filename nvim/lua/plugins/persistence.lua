vim.pack.add({
  { src = "https://github.com/folke/persistence.nvim" },
})

local ok, persistence = pcall(require, "persistence")
if not ok then
  return
end

vim.opt.sessionoptions = {
  "buffers",
  "curdir",
  "folds",
  "help",
  "tabpages",
  "winsize",
  "terminal",
}

persistence.setup({})

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 then
      persistence.load()
    end
  end,
})

vim.keymap.set("n", "<leader>qs", function()
  persistence.load()
end, { desc = "Restore session" })

vim.keymap.set("n", "<leader>ql", function()
  persistence.load({ last = true })
end, { desc = "Restore last session" })

vim.keymap.set("n", "<leader>qd", function()
  persistence.stop()
end, { desc = "Stop session saving" })
