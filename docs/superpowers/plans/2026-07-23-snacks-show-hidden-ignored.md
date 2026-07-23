# Snacks Hidden and Git-Ignored Files Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Show hidden and Git-ignored files by default in Snacks Explorer, file search, and grep.

**Architecture:** Keep the existing Snacks plugin declaration and layouts intact. Add explicit visibility options to the three relevant picker sources under `opts.picker.sources`: `explorer`, `files`, and `grep`. The top-level `opts.explorer` block remains limited to general explorer settings.

**Tech Stack:** Lua, Neovim, lazy.nvim, folke/snacks.nvim.

## Global Constraints

- Change only the Snacks configuration required for file visibility.
- Preserve existing Explorer layout, picker layout, keymaps, and unrelated working-tree changes.
- Set both `hidden = true` and `ignored = true` for each affected source.

---

### Task 1: Configure Snacks visibility and validate the source options

**Files:**
- Modify: `lua/plugins/editor/snacks.lua:9-28`
- Test: inline headless Neovim assertion; no repository test file needs modification for this config-only change.

**Interfaces:**
- Consumes: Existing `opts.explorer` and `opts.picker.sources` configuration.
- Produces: Snacks source options with hidden and Git-ignored files enabled.

- [ ] **Step 1: Add explicit source options**

Inside `picker.sources`, update the existing Explorer source and add file/grep source options:

```lua
          files = { hidden = true, ignored = true },
          grep = { hidden = true, ignored = true },
          explorer = {
            hidden = true,
            ignored = true,
            layout = { layout = { position = 'right' } },
          },
```

- [ ] **Step 2: Assert the Lua table contains the intended options**

Run:

```bash
nvim --headless -u NONE -c "lua local spec = dofile('lua/plugins/editor/snacks.lua'); local sources = spec[1].opts.picker.sources; assert(sources.files.hidden and sources.files.ignored); assert(sources.grep.hidden and sources.grep.ignored); assert(sources.explorer.hidden and sources.explorer.ignored)" -c 'qa!'
```

Expected: exit status `0` with no assertion error.

- [ ] **Step 3: Run the existing Neovim test suite if dependencies are available**

Run each repository spec through the configured Neovim setup:

```bash
for test in tests/*_spec.lua; do nvim --headless -u init.lua -c "luafile $test" -c 'qa!'; done
```

Expected: each test exits successfully. If a test cannot run because the local plugin installation is unavailable, report that limitation separately from the targeted config assertion.

- [ ] **Step 4: Inspect the final diff**

Run:

```bash
git diff -- lua/plugins/editor/snacks.lua
git status --short
```

Expected: the Snacks diff contains only the new `hidden = true` and `ignored = true` settings; pre-existing user changes remain unstaged and untouched.

- [ ] **Step 5: Commit the implementation when Git permissions allow it**

```bash
git add lua/plugins/editor/snacks.lua
git commit -m "feat: show hidden and ignored snacks files"
```

If the environment still prevents writing `.git/index`, leave the source change in the working tree and report that the commit could not be created.
