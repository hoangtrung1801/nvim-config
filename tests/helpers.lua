local M = {}

function M.collect()
  return {}
end

function M.check(failures, condition, message)
  if not condition then
    failures[#failures + 1] = message
  end
end

function M.plugins()
  return require('lazy.core.config').plugins
end

function M.finish(failures)
  if #failures > 0 then
    error(table.concat(failures, '\n'))
  end
end

return M
