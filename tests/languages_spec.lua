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

  h.check(
    failures,
    vim.filetype.match { filename = 'docker-compose.yml' }
      == 'yaml.docker-compose',
    'Docker Compose filetype routing is missing'
  )
  h.check(
    failures,
    vim.tbl_contains(
      vim.lsp.config.docker_compose_language_service.filetypes or {},
      'yaml.docker-compose'
    ),
    'Docker Compose LSP filetype is missing'
  )
  h.check(
    failures,
    vim.tbl_contains(vim.lsp.config.marksman.filetypes or {}, 'mdx'),
    'Marksman must support the mdx filetype'
  )
  h.check(
    failures,
    registry.formatters_by_ft.mdx ~= nil,
    'MDX formatter is missing'
  )
  h.check(failures, registry.linters_by_ft.mdx ~= nil, 'MDX linter is missing')
end

h.finish(failures)
