return {
  {
    'scottmckendry/cyberdream.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('cyberdream').setup {
        transparent = true,
        italic_comments = true,
        borderless_telescope = false,
      }
      -- vim.cmd [[colorscheme cyberdream-light]]
      vim.cmd [[colorscheme cyberdream-light]]
    end,
  },
  -- {
  --   'gbprod/nord.nvim',
  --   lazy = false,
  --   priority = 10000,
  --   config = function()
  --     -- require('nord').setup {
  --     --   transparent = true,
  --     --   italic_comments = true,
  --     --   borderless_telescope = false,
  --     -- }
  --     require('nord').setup {
  --       transparent = true,
  --     }
  --     vim.cmd [[colorscheme nord]]
  --     -- vim.cmd.colorscheme('nord')
  --   end,
  -- },
}
