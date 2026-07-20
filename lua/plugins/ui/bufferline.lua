return {
  {
    'akinsho/bufferline.nvim',
    version = '*',
    event = 'VeryLazy',
    dependencies = { 'nvim-mini/mini.nvim' },
    opts = {
      options = {
        mode = 'buffers',
        separator_style = 'slant',
      },
    },
  },
}
