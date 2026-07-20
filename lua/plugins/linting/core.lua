return {
  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'
      lint.linters_by_ft = require('config.languages').linters_by_ft
      local warned = {}

      local function run()
        if not vim.bo.modifiable or vim.bo.filetype == 'bigfile' then
          return
        end
        for _, name in ipairs(lint.linters_by_ft[vim.bo.filetype] or {}) do
          local linter = lint.linters[name]
          local cmd = linter and linter.cmd
          if type(cmd) == 'function' then
            cmd = cmd()
          end
          if type(cmd) == 'table' then
            cmd = cmd[1]
          end
          if type(cmd) == 'string' and vim.fn.executable(cmd) == 1 then
            lint.try_lint(name)
          elseif not warned[name] then
            warned[name] = true
            vim.notify(
              ('Linter %s is unavailable; run :MasonToolsInstall'):format(name),
              vim.log.levels.WARN
            )
          end
        end
      end

      vim.api.nvim_create_autocmd(
        { 'BufEnter', 'BufWritePost', 'InsertLeave' },
        {
          group = vim.api.nvim_create_augroup('config-lint', { clear = true }),
          callback = run,
        }
      )
    end,
  },
}
