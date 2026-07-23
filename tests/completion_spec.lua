local h = dofile(vim.fn.getcwd() .. '/tests/helpers.lua')
local failures = h.collect()
local plugins = h.plugins()

h.check(failures, plugins['blink.cmp'] ~= nil, 'blink.cmp must be installed')
h.check(failures, plugins['blink-copilot'] ~= nil, 'blink-copilot must be installed')
h.check(failures, plugins['copilot.lua'] ~= nil, 'copilot.lua must be installed')
h.check(failures, plugins['nvim-cmp'] == nil, 'nvim-cmp must be removed')
h.check(failures, plugins['LuaSnip'] == nil, 'LuaSnip must be removed')
h.check(failures, plugins['cmp-nvim-lsp'] == nil, 'cmp-nvim-lsp must be removed')
h.check(failures, plugins['cmp-path'] == nil, 'cmp-path must be removed')
h.check(failures, plugins['cmp_luasnip'] == nil, 'cmp_luasnip must be removed')
h.check(failures, plugins['nvim-autopairs'] == nil, 'nvim-autopairs must be removed')
h.check(
  failures,
  plugins['blink.cmp'].opts.sources.providers.copilot.module == 'blink-copilot',
  'blink.cmp must use blink-copilot as the Copilot provider'
)
h.check(
  failures,
  plugins['mini.hipatterns'] == nil,
  'standalone mini.hipatterns must be removed'
)
h.finish(failures)
