-- TODO: Test 1
-- Highlight todo, notes, etc in comments
return {
  'folke/todo-comments.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  },
  config = function()
    require('todo-comments').setup {}
    vim.keymap.set('n', '<leader>st', ':TodoTelescope <CR>', { desc = '[S]earch [T]odo' })
  end,
}
-- TODO: Test 2
