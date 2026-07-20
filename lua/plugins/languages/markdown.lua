return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { 'markdown', 'markdown.mdx' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {
      file_types = { 'markdown', 'markdown.mdx' },
      code = { sign = false, width = 'block', right_pad = 1 },
      heading = { sign = false, icons = {} },
      checkbox = { enabled = false },
    },
    config = function(_, opts)
      require('render-markdown').setup(opts)
      Snacks.toggle({
        name = 'Render Markdown',
        get = function()
          return require('render-markdown.state').enabled
        end,
        set = function(enabled)
          local render = require 'render-markdown'
          if enabled then
            render.enable()
          else
            render.disable()
          end
        end,
      }):map '<leader>um'
    end,
  },
}
