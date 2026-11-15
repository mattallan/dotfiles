vim.pack.add({
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/nvim-telescope/telescope.nvim" },
})

-- Globs excluded from rg-based pickers. rg never descends into these (real speedup),
-- unlike file_ignore_patterns which only filters results after the walk.
local rg_excludes = {
    "--glob", "!**/.claude/worktrees/**",
    "--glob", "!**/.git/**",
}

-- Grep preview that puts the match near the top of the window instead of centring it.
-- Telescope's built-in vimgrep previewer hardcodes `zz` with no option to change it.
local preview_lines_above_match = 5
local preview_ns = vim.api.nvim_create_namespace("grep_preview_top")

local function grep_previewer_top(opts)
    local previewers = require("telescope.previewers")
    local from_entry = require("telescope.from_entry")
    local conf = require("telescope.config").values

    return previewers.new_buffer_previewer({
        title = "Grep Preview",
        dyn_title = function(_, entry)
            return vim.fn.fnamemodify(from_entry.path(entry, false, false), ":~:.")
        end,
        get_buffer_by_name = function(_, entry)
            return from_entry.path(entry, false, false)
        end,
        define_preview = function(self, entry)
            local path = from_entry.path(entry, true, false)
            if path == nil or path == "" then
                return
            end

            conf.buffer_previewer_maker(path, self.state.bufnr, {
                bufname = self.state.bufname,
                winid = self.state.winid,
                callback = function(bufnr)
                    if not entry.lnum or entry.lnum < 1 then
                        return
                    end

                    pcall(vim.api.nvim_buf_clear_namespace, bufnr, preview_ns, 0, -1)
                    pcall(vim.hl.range, bufnr, preview_ns, "TelescopePreviewLine", { entry.lnum - 1, 0 }, { entry.lnum - 1, -1 })
                    -- The global scrolloff = 999 would re-centre the cursor.
                    pcall(vim.api.nvim_set_option_value, "scrolloff", 0, { win = self.state.winid })
                    pcall(vim.api.nvim_win_call, self.state.winid, function()
                        vim.fn.winrestview({
                            lnum = entry.lnum,
                            col = 0,
                            topline = math.max(1, entry.lnum - preview_lines_above_match),
                        })
                    end)
                end,
            })
        end,
    })
end

require("telescope").setup({
    defaults = {
        grep_previewer = grep_previewer_top,
        qflist_previewer = grep_previewer_top,
        -- live_grep / grep_string command
        vimgrep_arguments = vim.list_extend({
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
        }, rg_excludes),
        -- belt-and-suspenders: also drop these from any picker's results
        file_ignore_patterns = {
            "%.claude/worktrees/",
            "%.git/",
        },
    },
    pickers = {
        find_files = {
            find_command = vim.list_extend({
                "rg", "--files", "--color", "never", "--hidden",
            }, rg_excludes),
        },
        buffers = {
            mappings = {
                i = {
                    ["<C-d>"] = require('telescope.actions').delete_buffer,
                },
                n = {
                    ["dd"] = require('telescope.actions').delete_buffer,
                },
            },
        },
    },
})

local builtin = require("telescope.builtin")
vim.keymap.set('n', '<leader>f', builtin.find_files, { desc = 'Find Files' })
vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = 'Search Recent Files ("." for repeat)' })

vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = 'Find existing buffers' })
vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = 'Search by Grep' })
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = 'Search Help' })
vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = 'Search Keymaps' })
vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = 'Search Select Telescope' })
vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = 'Search current Word' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = 'Search Diagnostics' })
vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = 'Search Resume' })
vim.keymap.set('n', '<leader>sf', function() builtin.lsp_document_symbols({ symbols = { "function", "method" }}) end, { desc = "Functions in file" })

vim.keymap.set('n', '<leader>gs', function()
  require("telescope.builtin").git_status({
    use_git_root = true,
    initial_mode = 'normal',
  })
end, { desc = "Git status" })
vim.keymap.set("n", "<leader>gf", builtin.git_files, { desc = "Git files" })
