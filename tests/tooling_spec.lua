local h = dofile(vim.fn.getcwd() .. '/tests/helpers.lua')
local failures = h.collect()
local registry = require 'config.languages'

require('lazy').load {
  plugins = { 'conform.nvim', 'nvim-lint', 'nvim-treesitter' },
}

local conform = require 'conform'
local lint = require 'lint'
h.check(
  failures,
  vim.deep_equal(conform.formatters_by_ft, registry.formatters_by_ft),
  'Conform must use the registry'
)
h.check(
  failures,
  vim.deep_equal(lint.linters_by_ft, registry.linters_by_ft),
  'nvim-lint must use the registry'
)
h.check(
  failures,
  vim.o.foldmethod == 'expr',
  'foldmethod must use native expr folding'
)
h.check(
  failures,
  vim.o.foldexpr == 'v:lua.vim.treesitter.foldexpr()',
  'foldexpr must use native Tree-sitter'
)

h.finish(failures)
