return {
  'booperlv/nvim-gomove',
  opts = {
    map_defaults = false,
    reindent = true,
  },
  config = function()
    vim.keymap.set('n', '<leader>j', '<Plug>GoNSMDown', { desc = 'Move line Down' })
    vim.keymap.set('n', '<leader>k', '<Plug>GoNSMUp', { desc = 'Move line Up' })
  end,
}
