# Project Session Saving Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add dependency-free, project-based automatic session saving and restoration to this Neovim configuration.

**Architecture:** A focused `lua/config/session.lua` module owns session path generation, save/restore/delete operations, commands, and lifecycle autocmds. `init.lua` initializes it after the existing options and keymaps; `lua/keymaps.lua` exposes explicit leader mappings. Sessions live below `vim.fn.stdpath('state')` and are keyed by a SHA-256 digest of the absolute working directory.

**Tech Stack:** Neovim Lua APIs, built-in `:mksession`/`:source`, existing headless Lua specs, StyLua formatting.

## Global Constraints

- Do not add a plugin dependency.
- Restore only when Neovim starts without file arguments.
- Save on `VimLeavePre` only for eligible working directories.
- Do not create sessions for `/` or the user's home directory.
- Session failures must notify at error level without blocking startup or exit.
- Preserve all unrelated existing worktree changes.

## File Map

- Create `lua/config/session.lua`: session path policy, operations, commands, and lifecycle autocmds.
- Modify `init.lua`: call `require('config.session').setup()` after existing core setup.
- Modify `lua/keymaps.lua`: add explicit save, restore, and delete mappings.
- Create `tests/session_spec.lua`: behavior tests for path policy, save/restore/delete, and startup argument guards.

### Task 1: Add failing session behavior specs

**Files:**
- Create: `tests/session_spec.lua`

**Interfaces:**
- The tests consume `require('config.session')` with `session_path(dir)`, `save()`, `restore()`, `delete()`, and `should_restore(argv)`.
- The implementation will provide those functions in Task 2.

- [ ] **Step 1: Write the failing test**

Create a headless Neovim spec that uses a temporary directory and real session files:

```lua
local h = dofile(vim.fn.getcwd() .. '/tests/helpers.lua')
local failures = h.collect()
local session = require('config.session')

local root = vim.fn.tempname()
vim.fn.mkdir(root, 'p')
local project = root .. '/project'
local other_project = root .. '/other-project'
vim.fn.mkdir(project, 'p')
vim.fn.mkdir(other_project, 'p')

h.check(failures, session.session_path(project) ~= nil, 'project sessions must have a path')
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
h.check(failures, vim.fn.filereadable(saved_path) == 1, 'save must write a session file')

vim.cmd('only')
session.restore()
h.check(
  failures,
  vim.fn.bufname(0):match('session%-test%.txt$') ~= nil,
  'restore must source the saved buffer'
)

session.delete()
h.check(failures, vim.fn.filereadable(saved_path) == 0, 'delete must remove the session file')
vim.cmd('lcd ' .. vim.fn.fnameescape(original_dir))
vim.fn.delete(root, 'rf')

h.finish(failures)
```

- [ ] **Step 2: Run the test to verify it fails**

Run:

```bash
nvim --headless -u NONE -c "set rtp+=$PWD" -c "luafile tests/session_spec.lua" -c 'qa!'
```

Expected: FAIL because `config.session` does not exist yet. The failure must be a missing module, not a malformed test.

### Task 2: Implement the session module and lifecycle wiring

**Files:**
- Create: `lua/config/session.lua`
- Modify: `init.lua`

**Interfaces:**
- `session.session_path(directory)` returns a session filename or `nil` for an ineligible directory.
- `session.should_restore(argv)` returns a boolean based on command-line file arguments.
- `session.save()`, `session.restore()`, and `session.delete()` operate on the current working directory.
- `session.setup()` registers commands/autocmds and performs guarded `VimEnter` restoration.

- [ ] **Step 1: Write the minimal implementation**

Create `lua/config/session.lua` with this behavior:

```lua
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
```

Add this line to `init.lua` after `require 'keymaps'`:

```lua
require('config.session').setup()
```

- [ ] **Step 2: Run the focused test to verify it passes**

Run:

```bash
nvim --headless -u init.lua -c "luafile tests/session_spec.lua" -c 'qa!'
```

Expected: exit code 0 with no `Session` error notification.

### Task 3: Add explicit user controls

**Files:**
- Modify: `lua/keymaps.lua`

**Interfaces:**
- Normal-mode mappings call the user commands registered by `config.session`.

- [ ] **Step 1: Add the mappings**

Append these mappings after the existing tab mappings:

```lua
keymap.set('n', '<leader>qs', '<cmd>SessionSave<cr>', { desc = 'Save Session' })
keymap.set('n', '<leader>qr', '<cmd>SessionRestore<cr>', { desc = 'Restore Session' })
keymap.set('n', '<leader>qd', '<cmd>SessionDelete<cr>', { desc = 'Delete Session' })
```

- [ ] **Step 2: Add mapping assertions to the existing UX spec**

Extend the mapping list in `tests/ux_spec.lua` with:

```lua
  '<leader>qs',
  '<leader>qr',
  '<leader>qd',
```

- [ ] **Step 3: Run focused and existing specs**

Run:

```bash
nvim --headless -u init.lua -c "luafile tests/session_spec.lua" -c 'qa!'
nvim --headless -u init.lua -c "luafile tests/ux_spec.lua" -c 'qa!'
nvim --headless -u init.lua -c "luafile tests/plugin_graph_spec.lua" -c 'qa!'
```

Expected: all three commands exit 0.

### Task 4: Format and verify the complete configuration

**Files:**
- Modify only the files created or named above if formatting is needed.

- [ ] **Step 1: Format changed Lua files**

Run:

```bash
stylua init.lua lua/config/session.lua lua/keymaps.lua tests/session_spec.lua tests/ux_spec.lua
```

- [ ] **Step 2: Run all repository specs**

Run:

```bash
for spec in tests/*_spec.lua; do
  nvim --headless -u init.lua -c "luafile $spec" -c 'qa!'
done
```

Expected: every spec exits 0.

- [ ] **Step 3: Verify startup and diff hygiene**

Run:

```bash
nvim --headless -u init.lua -i NONE -n +qa
git diff --check
git status --short
```

Expected: Neovim exits 0, `git diff --check` produces no output, and status lists only the session implementation/spec files plus pre-existing user changes.
