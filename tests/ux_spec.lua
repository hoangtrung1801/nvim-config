local helpers = dofile(vim.fn.getcwd() .. '/tests/helpers.lua')
local failures = helpers.collect()
local plugins = helpers.plugins()

helpers.check(failures, plugins['snacks.nvim'] ~= nil, 'Snacks is missing')
helpers.check(
  failures,
  plugins['smart-splits.nvim'] ~= nil,
  'smart-splits is missing'
)

for _, plugin in ipairs {
  'fzf-lua',
  'neo-tree.nvim',
  'dressing.nvim',
  'lazygit.nvim',
  'indent-blankline.nvim',
  'tmux.nvim',
  'vim-tmux-navigator',
  'flit.nvim',
} do
  helpers.check(
    failures,
    plugins[plugin] == nil,
    plugin .. ' is still configured'
  )
end

local function has_normal_map(lhs)
  lhs = lhs:gsub('<leader>', vim.g.mapleader or '\\')
  return vim.fn.maparg(lhs, 'n') ~= ''
end

for _, lhs in ipairs {
  '<leader>e',
  '<leader>ff',
  '<leader>fg',
  '<leader>fb',
  '<leader>sg',
  '<leader>ss',
  '<leader>sS',
  '<leader>wv',
  '<leader>ws',
  's',
} do
  helpers.check(failures, has_normal_map(lhs), lhs .. ' mapping is missing')
end

helpers.finish(failures)
