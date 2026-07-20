local function smart_splits(method)
  return function()
    require('smart-splits')[method]()
  end
end

return {
  {
    'mrjones2014/smart-splits.nvim',
    version = '>=2.0.0',
    lazy = false,
    opts = {},
    keys = {
      {
        '<C-h>',
        smart_splits 'move_cursor_left',
        desc = 'Move to Left Window',
      },
      {
        '<C-j>',
        smart_splits 'move_cursor_down',
        desc = 'Move to Lower Window',
      },
      { '<C-k>', smart_splits 'move_cursor_up', desc = 'Move to Upper Window' },
      {
        '<C-l>',
        smart_splits 'move_cursor_right',
        desc = 'Move to Right Window',
      },
      { '<M-h>', smart_splits 'resize_left', desc = 'Resize Left' },
      { '<M-j>', smart_splits 'resize_down', desc = 'Resize Down' },
      { '<M-k>', smart_splits 'resize_up', desc = 'Resize Up' },
      { '<M-l>', smart_splits 'resize_right', desc = 'Resize Right' },
    },
  },
}
