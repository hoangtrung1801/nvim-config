local h = dofile(vim.fn.getcwd() .. '/tests/helpers.lua')
local failures = h.collect()
local session = require('config.session')

local root = vim.fn.tempname()
vim.fn.mkdir(root, 'p')
local project = root .. '/project'
local other_project = root .. '/other-project'
vim.fn.mkdir(project, 'p')
vim.fn.mkdir(other_project, 'p')

h.check(
  failures,
  session.session_path(project) ~= nil,
  'project sessions must have a path'
)
h.check(
  failures,
  session.session_path(project) ~= session.session_path(other_project),
  'different projects must not share a session path'
)
h.check(failures, session.session_path('/') == nil, 'root must not get a session')
h.check(
  failures,
  session.should_restore({}) == true,
  'startup without file arguments must restore'
)
h.check(
  failures,
  session.should_restore({ 'notes.md' }) == false,
  'startup with file arguments must not restore'
)

local original_dir = vim.fn.getcwd()
vim.cmd('lcd ' .. vim.fn.fnameescape(project))
vim.cmd('enew')
vim.cmd('file session-test.txt')
session.save()
local saved_path = session.session_path(project)
h.check(
  failures,
  vim.fn.filereadable(saved_path) == 1,
  'save must write a session file'
)

vim.cmd('only')
session.restore()
h.check(
  failures,
  vim.fn.bufname(0):match('session%-test%.txt$') ~= nil,
  'restore must source the saved buffer'
)

-- Verify neo-tree window and buffer are ignored during save
vim.cmd('lcd ' .. vim.fn.fnameescape(project))
vim.cmd('enew')
vim.cmd('file session-test-neotree.txt')
vim.cmd('vsplit')
local neo_buf = vim.api.nvim_create_buf(false, true)
vim.bo[neo_buf].filetype = 'neo-tree'
vim.api.nvim_win_set_buf(0, neo_buf)
session.save()
local session_content = vim.fn.readfile(saved_path)
local has_neotree = false
for _, line in ipairs(session_content) do
  if line:match('neo%-tree') then
    has_neotree = true
    break
  end
end
h.check(
  failures,
  not has_neotree,
  'session file must not contain neo-tree windows or buffers'
);
session.delete()
h.check(
  failures,
  vim.fn.filereadable(saved_path) == 0,
  'delete must remove the session file'
)
vim.cmd('lcd ' .. vim.fn.fnameescape(original_dir))
vim.fn.delete(root, 'rf')

h.finish(failures)
