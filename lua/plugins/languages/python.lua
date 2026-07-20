return {
  {
    'linux-cultist/venv-selector.nvim',
    branch = 'main',
    ft = 'python',
    dependencies = { 'folke/snacks.nvim' },
    opts = {
      options = {
        picker = 'snacks',
        cached_venv_automatic_activation = true,
        require_lsp_activation = true,
      },
    },
    keys = {
      {
        '<leader>vs',
        '<cmd>VenvSelect<cr>',
        desc = 'Select Python Environment',
      },
    },
  },
}
