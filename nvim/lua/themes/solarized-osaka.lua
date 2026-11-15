vim.pack.add({
    { src = "https://github.com/craftzdog/solarized-osaka.nvim" },
})

require("solarized-osaka").setup({
    style = "vivid",
    transparent = true, -- let Ghostty's opacity/blur show through
})

vim.cmd.colorscheme("solarized-osaka")

vim.opt.pumblend = 10 -- slightly translucent completion popup
