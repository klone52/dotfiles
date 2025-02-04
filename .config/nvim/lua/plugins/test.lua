return {
  'nvim-neotest/neotest',
  ft = { 'go', 'rust', 'python', 'cs', 'typescript', 'javascript' },
  dependencies = {
    'nvim-neotest/neotest-go',
    'nvim-neotest/neotest-python',
    'rouge8/neotest-rust',
    'Issafalcon/neotest-dotnet',
    'klone52/neotest-jest',
    'nvim-treesitter/nvim-treesitter',
  },
  opts = function()
    return {
      -- your neotest config here
      adapters = {
        require 'neotest-dotnet',
        require 'neotest-python',
        require 'neotest-rust',
        require 'neotest-go',
        require 'neotest-jest' {
          skipDependencyCheck = true,
        },
      },
    }
  end,
  config = function(_, opts)
    -- get neotest namespace (api call creates or returns namespace)
    local neotest_ns = vim.api.nvim_create_namespace 'neotest'
    vim.diagnostic.config({
      virtual_text = {
        format = function(diagnostic)
          local message = diagnostic.message:gsub('\n', ' '):gsub('\t', ' '):gsub('%s+', ' '):gsub('^%s+', '')
          return message
        end,
      },
    }, neotest_ns)
    require('neotest').setup(opts)
  end,
  keys = {
    { '<leader>t', '', desc = '+test' },
    {
      '<leader>tt',
      function()
        require('neotest').run.run(vim.fn.expand '%')
      end,
      desc = 'Run File (Neotest)',
    },
    {
      '<leader>tT',
      function()
        require('neotest').run.run(vim.uv.cwd())
      end,
      desc = 'Run All Test Files (Neotest)',
    },
    {
      '<leader>tr',
      function()
        require('neotest').run.run()
      end,
      desc = 'Run Nearest (Neotest)',
    },
    {
      '<leader>tl',
      function()
        require('neotest').run.run_last()
      end,
      desc = 'Run Last (Neotest)',
    },
    {
      '<leader>ts',
      function()
        require('neotest').summary.toggle()
      end,
      desc = 'Toggle Summary (Neotest)',
    },
    {
      '<leader>to',
      function()
        require('neotest').output.open { enter = true, auto_close = true }
      end,
      desc = 'Show Output (Neotest)',
    },
    {
      '<leader>tO',
      function()
        require('neotest').output_panel.toggle()
      end,
      desc = 'Toggle Output Panel (Neotest)',
    },
    {
      '<leader>tS',
      function()
        require('neotest').run.stop()
      end,
      desc = 'Stop (Neotest)',
    },
    {
      '<leader>tw',
      function()
        require('neotest').watch.toggle(vim.fn.expand '%')
      end,
      desc = 'Toggle Watch (Neotest)',
    },
  },
}
