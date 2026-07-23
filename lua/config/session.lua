local M = {}

local session_dir = vim.fn.stdpath('state') .. '/sessions'

local function notify_error(message)
  vim.notify(message, vim.log.levels.ERROR, { title = 'Session' })
end

local function eligible(directory)
  local home = vim.fn.expand('~')
  return directory ~= ''
    and vim.fn.isdirectory(directory) == 1
    and directory ~= '/'
    and directory ~= home
end

local function normalize(directory)
  local uv = vim.uv or vim.loop
  return uv.fs_realpath(directory) or vim.fn.fnamemodify(directory, ':p')
end

function M.session_path(directory)
  directory = normalize(directory or vim.fn.getcwd())
  if not eligible(directory) then
    return nil
  end
  return session_dir .. '/' .. vim.fn.sha256(directory) .. '.vim'
end

function M.should_restore(argv)
  return #argv == 0
end

function M.save()
  local path = M.session_path()
  if not path then
    return
  end

  if vim.fn.mkdir(session_dir, 'p') == 0 and vim.fn.isdirectory(session_dir) ~= 1 then
    notify_error('Could not create session directory: ' .. session_dir)
    return
  end

  local ok, err = pcall(vim.cmd, 'mksession! ' .. vim.fn.fnameescape(path))
  if not ok then
    notify_error('Could not save session: ' .. tostring(err))
  end
end

function M.restore()
  local path = M.session_path()
  if not path or vim.fn.filereadable(path) ~= 1 then
    return
  end

  local ok, err = pcall(vim.cmd, 'source ' .. vim.fn.fnameescape(path))
  if not ok then
    notify_error('Could not restore session: ' .. tostring(err))
  end
end

function M.delete()
  local path = M.session_path()
  if not path or vim.fn.filereadable(path) ~= 1 then
    return
  end

  if vim.fn.delete(path) ~= 0 then
    notify_error('Could not delete session: ' .. path)
  end
end

function M.setup()
  vim.api.nvim_create_user_command('SessionSave', M.save, {})
  vim.api.nvim_create_user_command('SessionRestore', M.restore, {})
  vim.api.nvim_create_user_command('SessionDelete', M.delete, {})

  local group = vim.api.nvim_create_augroup('project-session', { clear = true })
  vim.api.nvim_create_autocmd('VimEnter', {
    group = group,
    callback = function()
      if vim.fn.argc() == 0 then
        vim.schedule(M.restore)
      end
    end,
  })
  vim.api.nvim_create_autocmd('VimLeavePre', {
    group = group,
    callback = M.save,
  })
end

return M
