return {
  {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    cmd = 'ConformInfo',
    keys = {
      {
        '<leader>cf',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = { 'n', 'x' },
        desc = 'Format',
      },
    },
    opts = function()
      Snacks.toggle({
        name = 'Autoformat (Global)',
        get = function()
          return not vim.g.disable_autoformat
        end,
        set = function(state)
          vim.g.disable_autoformat = not state
        end,
      }):map '<leader>uf'

      return {
        formatters_by_ft = require('config.languages').formatters_by_ft,
        default_format_opts = { lsp_format = 'fallback' },
        format_on_save = function(bufnr)
          if
            vim.g.disable_autoformat
            or vim.b[bufnr].disable_autoformat
            or vim.bo[bufnr].filetype == 'bigfile'
          then
            return
          end
          return { timeout_ms = 2000, lsp_format = 'fallback' }
        end,
      }
    end,
  },
}
