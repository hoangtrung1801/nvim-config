# GitHub Copilot Blink Completion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add GitHub Copilot suggestions to the existing `blink.cmp` completion menu.

**Architecture:** Keep `blink.cmp` as the completion UI, use `zbirenbaum/copilot.lua` as the Copilot LSP client, and use `fang2hou/blink-copilot` as the async Blink source adapter. Disable Copilot's native suggestion and panel UIs to avoid competing completion surfaces.

**Tech Stack:** Neovim 0.11.4, lazy.nvim, Lua, blink.cmp v1, copilot.lua, blink-copilot.

## Global Constraints

- Preserve existing LSP, path, snippets, buffer, and LazyDev completion sources.
- Load Copilot lazily on `InsertEnter` and expose `:Copilot` for authentication.
- Do not put credentials or tokens in the repository.
- Do not change CodeCompanion's Copilot adapter.

---

### Task 1: Add failing completion-graph assertions

**Files:**
- Modify: `tests/plugin_graph_spec.lua`
- Modify: `tests/completion_spec.lua`

**Interfaces:**
- Consumes: the existing lazy.nvim plugin registry and Blink config.
- Produces: failing assertions requiring `copilot.lua`, `blink-copilot`, and a configured `copilot` Blink provider.

- [ ] **Step 1: Write the failing test**

Add `copilot.lua` and `blink-copilot` to the required plugin list in `tests/plugin_graph_spec.lua`. In `tests/completion_spec.lua`, assert that both plugins exist and that `blink.cmp` has a `copilot` provider whose module is `blink-copilot`.

- [ ] **Step 2: Run tests to verify they fail**

Run:

```bash
nvim --headless -u init.lua -i NONE -n -c "luafile tests/plugin_graph_spec.lua" -c "luafile tests/completion_spec.lua" -c "qa"
```

Expected: failure stating the Copilot plugins/provider are missing.

### Task 2: Implement Copilot as a Blink source

**Files:**
- Modify: `lua/plugins/coding/completion.lua`
- Create: `lua/plugins/coding/copilot.lua`

**Interfaces:**
- Consumes: existing Blink completion options and lazy.nvim imports.
- Produces: an async `copilot` Blink source backed by Copilot LSP.

- [ ] **Step 1: Add the Copilot plugin spec**

Create `lua/plugins/coding/copilot.lua`:

```lua
return {
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
    },
  },
}
```

- [ ] **Step 2: Register the Blink provider**

Extend `lua/plugins/coding/completion.lua` with `blink-copilot` as a dependency, add `copilot` to `sources.default`, and configure:

```lua
copilot = {
  name = 'Copilot',
  module = 'blink-copilot',
  async = true,
  score_offset = 100,
},
```

- [ ] **Step 3: Load the new import**

Add `{ import = 'plugins.coding.copilot' }` beside the existing coding plugin imports in `lua/lazy-init.lua`.

- [ ] **Step 4: Run the focused tests**

Run the command from Task 1. Expected: all assertions pass.

### Task 3: Verify startup and repository behavior

**Files:**
- No additional files.

**Interfaces:**
- Consumes: the completed lazy.nvim specs and test suite.
- Produces: verified startup, plugin graph, and completion configuration.

- [ ] **Step 1: Run the complete test suite**

Run:

```bash
for test in tests/*_spec.lua; do nvim --headless -u init.lua -i NONE -n -c "luafile $test" -c "qa" || exit 1; done
```

Expected: every test exits with status 0.

- [ ] **Step 2: Run a headless startup check**

Run:

```bash
nvim --headless -u init.lua -i NONE -n "+lua print('startup-ok')" +qa
```

Expected: output contains `startup-ok` and no Lua error.

- [ ] **Step 3: Inspect the final diff**

Run:

```bash
git diff -- lua/lazy-init.lua lua/plugins/coding/completion.lua lua/plugins/coding/copilot.lua tests/plugin_graph_spec.lua tests/completion_spec.lua
```

Confirm the diff contains only the Copilot/Blink integration and its assertions.
