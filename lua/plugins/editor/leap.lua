return {
  {
    'ggandor/leap.nvim',
    keys = {
      { 's', mode = { 'n', 'x', 'o' }, desc = 'Leap Forward' },
      { 'S', mode = { 'n', 'x', 'o' }, desc = 'Leap Backward' },
      { 'gs', mode = { 'n', 'x', 'o' }, desc = 'Leap Across Windows' },
    },
    config = function()
      require('leap').add_default_mappings()
    end,
  },
}
