vim.pack.add({ 'https://github.com/folke/flash.nvim' })

require('flash').setup({})

-- Shim for Neovim 0.13-dev: the C globals `search_match_lines` and
-- `search_match_endcol` that flash.hacks reads over FFI were moved into the
-- exported `Search` (SearchState) struct, so dlsym fails on every match lookup.
-- Remove once upstream flash.nvim supports the new layout.
do
  local ok_ffi, ffi = pcall(require, 'ffi')
  if ok_ffi then
    pcall(ffi.cdef, [[
      typedef struct {
        bool hl_match;
        int32_t match_lines;
        int match_endcol;
        int32_t first_line;
        int32_t last_line;
        bool no_smartcase;
        int cmdlen;
        bool no_hlsearch;
      } flash_shim_SearchState;
      flash_shim_SearchState Search;
    ]])

    if pcall(function() return ffi.C.Search.match_lines end) then
      local C = ffi.C
      local Hacks = require('flash.hacks')
      local Pos = require('flash.search.pos')
      local saved = {}

      function Hacks.get_end_pos(from)
        local ret = Pos({
          from[1] + C.Search.match_lines,
          math.max(0, C.Search.match_endcol - 1),
        })
        local line = vim.api.nvim_buf_get_lines(0, ret[1] - 1, ret[1], false)[1]
        local char_idx = vim.fn.charidx(line, ret[2])
        ret[2] = vim.fn.byteidx(line, char_idx)
        return ret
      end

      function Hacks.save_incsearch_state()
        saved = { match_endcol = C.Search.match_endcol, match_lines = C.Search.match_lines }
      end

      function Hacks.restore_incsearch_state()
        C.Search.match_endcol = saved.match_endcol or 0
        C.Search.match_lines = saved.match_lines or 0
      end
    end
  end
end

local map = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { desc = desc })
end

map({ 'n', 'x', 'o' }, 's', function() require('flash').jump() end, 'Flash')
map({ 'n', 'x', 'o' }, 'S', function() require('flash').treesitter() end, 'Flash Treesitter')
map('o', 'r', function() require('flash').remote() end, 'Remote Flash')
map({ 'o', 'x' }, 'R', function() require('flash').treesitter_search() end, 'Treesitter Search')
map('c', '<C-s>', function() require('flash').toggle() end, 'Toggle Flash Search')
