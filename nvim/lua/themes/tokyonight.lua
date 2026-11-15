vim.pack.add({
    { src = "https://github.com/folke/tokyonight.nvim" }
})

require("tokyonight").setup({
    style = "night", -- storm, night, moon, day
    -- No background of our own, so Ghostty's 0.92 opacity and blur show through.
    -- Floats keep a solid background so pickers and popups stay readable.
    transparent = true,
    styles = {
        sidebars = "transparent",
    },
})

vim.cmd.colorscheme("tokyonight-night")
