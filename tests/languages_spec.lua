local h = dofile(vim.fn.getcwd() .. '/tests/helpers.lua')
local failures = h.collect()
local ok, registry = pcall(require, 'config.languages')

h.check(failures, ok, 'config.languages must load')
if ok then
  require('lazy').load { plugins = { 'nvim-lspconfig' } }
  for _, name in ipairs {
    'lua_ls',
    'vtsls',
    'eslint',
    'astro',
    'pyright',
    'ruff',
    'gopls',
    'dockerls',
    'docker_compose_language_service',
    'tailwindcss',
    'cssls',
    'marksman',
  } do
    h.check(
      failures,
      registry.servers[name] ~= nil,
      name .. ' missing from registry'
    )
    h.check(
      failures,
      type(vim.lsp.config[name]) == 'table',
      name .. ' missing from vim.lsp.config'
    )
  end
end

h.finish(failures)
