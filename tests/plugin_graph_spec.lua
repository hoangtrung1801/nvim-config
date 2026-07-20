local h = dofile(vim.fn.getcwd() .. '/tests/helpers.lua')
local failures = h.collect()
local plugins = h.plugins()
local lazy_options = require('lazy.core.config').options

local required = {
  'blink.cmp',
  'bufferline.nvim',
  'codecompanion.nvim',
  'conform.nvim',
  'gitsigns.nvim',
  'grug-far.nvim',
  'lazy.nvim',
  'leap.nvim',
  'mini.nvim',
  'nvim-lint',
  'nvim-lspconfig',
  'nvim-treesitter',
  'overseer.nvim',
  'render-markdown.nvim',
  'smart-splits.nvim',
  'snacks.nvim',
  'trouble.nvim',
  'venv-selector.nvim',
  'which-key.nvim',
}

local removed = {
  'LuaSnip',
  'cmp-nvim-lsp',
  'cmp-path',
  'cmp_luasnip',
  'dressing.nvim',
  'flit.nvim',
  'fzf-lua',
  'lazygit.nvim',
  'mason-lspconfig.nvim',
  'mason-nvim-dap.nvim',
  'neo-tree.nvim',
  'neotest',
  'nvim-autopairs',
  'nvim-cmp',
  'nvim-dap',
  'nvim-ufo',
  'nvim-web-devicons',
  'promise-async',
  'telescope.nvim',
  'tmux.nvim',
  'vim-repeat',
  'vim-tmux-navigator',
}

for _, name in ipairs(required) do
  h.check(failures, plugins[name] ~= nil, name .. ' must remain')
end
for _, name in ipairs(removed) do
  h.check(failures, plugins[name] == nil, name .. ' must be removed')
end

h.check(
  failures,
  lazy_options.defaults.lazy == true,
  'plugins must be lazy by default'
)
h.check(
  failures,
  not vim.tbl_contains(lazy_options.performance.rtp.disabled_plugins, 'shada'),
  'shada must remain enabled for recent-file history'
)
h.check(
  failures,
  vim.filetype.match { filename = 'component.mdx' } == 'mdx',
  '.mdx files must be detected before the MDX plugin lazy-loads'
)

h.finish(failures)
