vim.pack.add({ 'https://github.com/folke/snacks.nvim' })

-- Only the scroll module: animates every view change, including the recentre
-- that `scrolloff = 999` causes on `}`, `{`, `[m` and friends, instead of snapping.
require('snacks').setup({
  scroll = {
    enabled = true,
    animate = {
      duration = { step = 10, total = 150 },
      easing = 'outQuad',
    },
    -- Holding a key or jumping in quick succession uses this shorter animation.
    animate_repeat = {
      delay = 100,
      duration = { step = 5, total = 50 },
      easing = 'linear',
    },
  },
})
