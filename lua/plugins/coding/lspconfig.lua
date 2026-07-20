local function lsp_action(kind)
  return function()
    vim.lsp.buf.code_action {
      apply = true,
      context = { only = { kind }, diagnostics = {} },
    }
  end
end

return {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'saghen/blink.cmp',
      { 'williamboman/mason.nvim', cmd = 'Mason', opts = {} },
      'WhoIsSethDaniel/mason-tool-installer.nvim',
    },
    config = function()
      local registry = require 'config.languages'
      require('mason-tool-installer').setup {
        ensure_installed = registry.tools,
        run_on_start = true,
        start_delay = 3000,
        debounce_hours = 24,
      }

      vim.lsp.config('*', {
        capabilities = require('blink.cmp').get_lsp_capabilities(),
      })
      for name, config in pairs(registry.servers) do
        vim.lsp.config(name, config)
      end
      vim.lsp.enable(vim.tbl_keys(registry.servers))

      local group = vim.api.nvim_create_augroup('config-lsp', { clear = true })
      local highlight_group =
        vim.api.nvim_create_augroup('config-lsp-highlight', { clear = true })
      vim.api.nvim_create_autocmd('LspAttach', {
        group = group,
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if not client then
            return
          end

          local function map(lhs, rhs, desc, mode)
            vim.keymap.set(mode or 'n', lhs, rhs, {
              buffer = event.buf,
              desc = desc,
              silent = true,
            })
          end

          map('gd', function()
            Snacks.picker.lsp_definitions()
          end, 'Goto Definition')
          map('gr', function()
            Snacks.picker.lsp_references()
          end, 'References')
          map('gI', function()
            Snacks.picker.lsp_implementations()
          end, 'Goto Implementation')
          map('gy', function()
            Snacks.picker.lsp_type_definitions()
          end, 'Goto Type Definition')
          map('gD', vim.lsp.buf.declaration, 'Goto Declaration')
          map(
            '<leader>ca',
            vim.lsp.buf.code_action,
            'Code Action',
            { 'n', 'x' }
          )
          map(']]', function()
            Snacks.words.jump(vim.v.count1)
          end, 'Next Reference')
          map('[[', function()
            Snacks.words.jump(-vim.v.count1)
          end, 'Previous Reference')

          if client:supports_method 'textDocument/inlayHint' then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(
                not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf },
                { bufnr = event.buf }
              )
            end, 'Toggle Inlay Hints')
          end

          if client.name == 'ruff' then
            client.server_capabilities.hoverProvider = false
          elseif client.name == 'vtsls' then
            map(
              '<leader>co',
              lsp_action 'source.organizeImports',
              'Organize Imports'
            )
            map(
              '<leader>cM',
              lsp_action 'source.addMissingImports.ts',
              'Add Missing Imports'
            )
            map(
              '<leader>cu',
              lsp_action 'source.removeUnused.ts',
              'Remove Unused Imports'
            )
            map('<leader>cD', lsp_action 'source.fixAll', 'Fix All Diagnostics')
          end

          if client:supports_method 'textDocument/documentHighlight' then
            vim.api.nvim_clear_autocmds {
              group = highlight_group,
              buffer = event.buf,
            }
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              group = highlight_group,
              buffer = event.buf,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              group = highlight_group,
              buffer = event.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })
    end,
  },
}
