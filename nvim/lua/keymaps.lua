-- Space is my leader.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Clear search highlighting.
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Close all open buffers.
vim.keymap.set('n', '<leader>Q', ':bufdo bdelete<CR>')

-- Easy insertion of a trailing ; or , from insert mode.
vim.keymap.set('i', ';;', '<Esc>A;<Esc>')
vim.keymap.set('i', ',,', '<Esc>A,<Esc>')

-- Claude Code in a centred float, toggled with <leader>cc (or <C-q> from inside it).
-- The terminal is hidden rather than closed, so the conversation survives a toggle.
-- Each directory gets one session named "nvim" with permission checks bypassed: the
-- first toggle starts it, later ones (even after restarting nvim) resume it.
local claude = { buf = nil, win = nil }

-- A stable session ID for the current directory, so its session can be found and
-- resumed without relying on a name lookup.
local function claude_session_id()
  local h = vim.fn.sha256('nvim:' .. vim.fn.getcwd())
  return string.format('%s-%s-5%s-8%s-%s', h:sub(1, 8), h:sub(9, 12), h:sub(14, 16), h:sub(18, 20), h:sub(21, 32))
end

local function claude_cmd()
  local id = claude_session_id()
  local config_dir = vim.env.CLAUDE_CONFIG_DIR or (vim.env.HOME .. '/.claude')
  local exists = vim.fn.glob(config_dir .. '/projects/*/' .. id .. '.jsonl') ~= ''
  local cmd = { 'claude', '--dangerously-skip-permissions' }
  if exists then
    vim.list_extend(cmd, { '--resume', id })
  else
    vim.list_extend(cmd, { '--session-id', id, '--name', 'nvim' })
  end
  return cmd
end

local function open_claude_window()
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  claude.win = vim.api.nvim_open_win(claude.buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = 'minimal',
    border = 'rounded',
    title = ' Claude ',
    title_pos = 'center',
  })
  vim.cmd.startinsert()
end

local function toggle_claude()
  if claude.win and vim.api.nvim_win_is_valid(claude.win) then
    vim.api.nvim_win_hide(claude.win)
    claude.win = nil
    return
  end

  if claude.buf and vim.api.nvim_buf_is_valid(claude.buf) then
    open_claude_window()
    return
  end

  claude.buf = vim.api.nvim_create_buf(false, true)
  open_claude_window()
  vim.fn.jobstart(claude_cmd(), {
    term = true,
    on_exit = function()
      if claude.win and vim.api.nvim_win_is_valid(claude.win) then
        vim.api.nvim_win_close(claude.win, true)
      end
      vim.api.nvim_buf_delete(claude.buf, { force = true })
      claude = { buf = nil, win = nil }
    end,
  })
  vim.keymap.set('t', '<C-q>', toggle_claude, { buffer = claude.buf, desc = 'Hide Claude' })
end

vim.keymap.set('n', '<leader>cc', toggle_claude, { desc = 'Toggle Claude' })


-- Copy the current file's path to the system clipboard.
local function yank_path(modifier, label)
  return function()
    local path = vim.fn.expand(modifier)
    vim.fn.setreg('+', path)
    vim.notify('Copied ' .. label .. ': ' .. path)
  end
end

vim.keymap.set('n', '<leader>yf', yank_path('%:.', 'relative path'), { desc = 'Yank relative file path' })
vim.keymap.set('n', '<leader>yp', yank_path('%:p', 'full path'), { desc = 'Yank full file path' })
