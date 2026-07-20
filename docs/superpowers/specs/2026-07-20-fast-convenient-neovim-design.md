# Fast and Convenient Neovim Design

## Goal

Modernize this Neovim 0.11.4 configuration for maximum startup and runtime speed while preserving a convenient keyboard-first workflow and full editing support for every currently configured language.

The redesign focuses on editing, completion, language intelligence, formatting, linting, navigation, search, and Git workflows. Integrated testing and debugging are explicitly out of scope.

## Current-State Findings

- The resolved Lazy graph contains 55 plugins, with 22 loaded during a headless startup audit.
- A measured headless startup reached approximately 65 ms, while Lazy completed later in the startup lifecycle.
- The main LSP configuration defines a private `servers` table and does not consume the `opts.servers` values contributed by language modules. Most language-specific LSP configuration is therefore ignored.
- Repeated optional specifications cause `nvim-dap` and `neotest` to disappear from the resolved plugin graph despite having core configuration files.
- FZF-Lua, Telescope, Neo-tree, and Snacks provide overlapping search or navigation capabilities.
- `nvim-cmp`, LuaSnip, and several cmp source plugins form a larger completion stack than the desired performance target requires.
- Both `tmux.nvim` and `vim-tmux-navigator` cover terminal-multiplexer navigation.
- `mini.nvim` is installed alongside standalone or duplicate functionality that it can already provide.
- The current working tree contains an untracked `.nvimlog`; it is user-owned and must remain untouched.

## Chosen Approach

Use an aggressively consolidated modern stack. Replace overlapping plugin groups with a small number of cohesive libraries, keep familiar keybindings where practical, and lazy-load everything that is not required to draw the first usable editor screen.

Two alternatives were rejected:

- A hybrid modernization would replace completion and repair LSP while retaining redundant picker and explorer stacks. It would reduce migration risk but miss the requested maximum-speed goal.
- An ultra-minimal native configuration would remove most enhanced completion and navigation interfaces. It would be faster in theory but would not meet the convenience requirement.

## Architecture

The configuration will have three clear layers.

### Startup Core

Only Lazy, the colorscheme, and the minimal Snacks core load eagerly. Startup-safe option and keymap modules remain plain Lua. All other plugins load through a filetype, command, key, or editor event.

Snacks big-file and quick-file facilities protect startup and opening performance. Expensive buffer-local features must not activate for files classified as large.

### Unified User Experience

Snacks becomes the common interface for:

- file, Git-file, buffer, symbol, command, and text search;
- the file explorer;
- `vim.ui.input` and `vim.ui.select`;
- notifications;
- indentation and scope display;
- terminal and Lazygit windows;
- large-file protection.

The existing specialized tools remain only when they provide distinct value: Trouble for diagnostics, Grug-far for project replacement, Gitsigns for Git hunks, CodeCompanion for AI workflows, Overseer for tasks, Which-key for key discovery, render-markdown for Markdown display, and bufferline for visible buffer navigation.

### Language Tooling

Neovim 0.11's `vim.lsp.config` and `vim.lsp.enable` APIs own server activation. `nvim-lspconfig` supplies upstream server definitions; Mason installs external tools; blink.cmp extends LSP capabilities and owns interactive completion.

One explicit language-tool table is the source of truth for server settings, Mason package names, Tree-sitter parsers, formatters, and linters. Language support must not depend on Lazy merging unrelated plugin specifications.

## Plugin Changes

### Completion

Replace these plugins:

- `nvim-cmp`
- LuaSnip
- `cmp-nvim-lsp`
- `cmp-path`
- `cmp_luasnip`

Use `blink.cmp` with its native LSP, path, buffer, and snippet support. Use Neovim-native snippets unless a concrete unsupported snippet requirement appears. Preserve `<C-n>`, `<C-p>`, `<C-Space>`, `<CR>`, `<Tab>`, and `<S-Tab>` behavior where blink supports the same interaction safely.

Use `mini.pairs` instead of `nvim-autopairs`. Completion confirmation must not depend on an nvim-cmp event adapter.

### Picker, Explorer, and UI

Remove FZF-Lua, Telescope, Neo-tree, Dressing, and Lazygit.nvim after their keymaps and workflows are represented through Snacks.

The Python virtual-environment workflow must not reintroduce Telescope. It must use a supported neutral or Snacks-compatible selector path. If the current venv-selector release cannot meet that constraint, use a lightweight command/input workflow backed by Python environment discovery rather than retaining Telescope solely for one feature.

### Motion and Multiplexer Navigation

Keep Leap as the targeted motion interface. Remove Flit and duplicate surround/repeat configuration.

Replace `tmux.nvim` and `vim-tmux-navigator` with one `smart-splits.nvim` integration. It owns seamless `Ctrl-h/j/k/l` navigation and resize mappings across Neovim and tmux.

### Mini Modules

Use the existing `mini.nvim` package as the sole source for:

- `mini.icons`;
- `mini.pairs`;
- `mini.surround`;
- `mini.hipatterns`.

Remove redundant standalone mini repositories and duplicated module setup. Compatibility shims may expose MiniIcons to plugins that expect `nvim-web-devicons`, avoiding an icon-only dependency where supported.

### Folding and Tree-sitter

Remove UFO and promise-async. Configure `vim.treesitter.foldexpr()` with conservative default fold levels so files open unfolded and native fold commands remain predictable.

Neovim remains at 0.11.4 for this project, so `nvim-treesitter` must stay on its legacy `master` branch. The incompatible rewritten `main` branch currently requires Neovim 0.12 and is outside this redesign.

### Removed Subsystems

Remove all DAP and neotest specifications, dependencies, keymaps, and language-specific adapters. Do not replace them in this iteration.

## User Experience and Keymaps

The redesign preserves the current mental model:

- `<leader>e` toggles the explorer and reveals the current file.
- `<leader>ff` searches files.
- `<leader>fg` searches Git-tracked files.
- `<leader>fb` and `<leader>,` switch buffers.
- `<leader>sg` performs live grep.
- `<leader>sr` opens project-wide replacement.
- `Shift-h`, `Shift-l`, `[b`, and `]b` move through buffers.
- Existing safe buffer-delete mappings remain.
- `Ctrl-h/j/k/l` navigates Neovim windows and tmux panes.
- Which-key retains the existing leader-group organization.

Picker, explorer, prompt, notification, and terminal windows share Snacks styling and action conventions. Any changed mapping must have a clear replacement and must not silently shadow another mapping.

## Supported Languages

The explicit server set is:

- Lua: `lua_ls`
- TypeScript and JavaScript: `vtsls` and `eslint`
- Astro: `astro`, including its TypeScript plugin integration
- Python: `pyright` and `ruff`
- Go: `gopls`
- Docker and Compose: `dockerls` and `docker_compose_language_service`
- Tailwind and CSS: `tailwindcss` and `cssls`
- Markdown and MDX: `marksman`, MDX parsing, and render-markdown

Server-specific behavior that currently provides value must survive the migration, including TypeScript import commands and inlay hints, Pyright hover with Ruff diagnostics/actions, detailed gopls analysis, Tailwind filetype filtering, and Astro's TypeScript plugin.

## Formatting and Linting

Formatting is deterministic by filetype:

- Web, Astro, Markdown, MDX, JSON, YAML, and CSS-family files use Prettierd with Prettier fallback.
- Lua uses Stylua.
- Python uses Ruff formatting and import organization.
- Go uses goimports and gofumpt.

Linting is limited to diagnostics not already supplied adequately by an active LSP:

- Dockerfiles use Hadolint.
- Markdown uses markdownlint-cli2.
- JavaScript and TypeScript diagnostics come from ESLint LSP.
- Python diagnostics come from Ruff LSP.

Missing external executables must produce a concise actionable notification at most once per relevant action; they must not throw stack traces or block editing. Format-on-save must retain the current timeout behavior and use LSP formatting only where explicitly allowed.

## Error Handling and Operational Behavior

- External tool installation must never block normal startup.
- Mason installation runs only through explicit installation/update flows or deferred background events supported by its integrations.
- Picker commands must degrade with a clear message when `rg` or `fd` is missing.
- Language servers and formatters must be validated by health checks without starting every server during startup.
- Large files skip expensive completion, syntax, rendering, and diagnostic work according to the centralized big-file policy.
- Plugin configuration errors must fail the headless smoke test rather than being hidden by broad `pcall` wrappers.
- No command may modify the user-owned `.nvimlog`.

## Verification Strategy

Configuration changes use a test-first smoke harness:

1. Add headless assertions that describe the desired plugin graph, keymaps, LSP server definitions, formatter mappings, and absence of removed plugins.
2. Run the assertions against the current configuration and confirm that they fail for the intended missing behavior.
3. Make the smallest configuration changes that satisfy each assertion group.
4. Run the smoke suite and a normal headless startup after every coherent migration step.

Final acceptance requires:

- zero startup errors;
- zero deprecated LSP API calls from local configuration;
- all listed server configurations resolve through `vim.lsp.config`;
- all formatter and linter mappings resolve without requiring their executables to run;
- consolidated picker and explorer keymaps point to valid Snacks functions;
- removed plugins are absent from both the resolved graph and lockfile;
- five warm headless startup measurements have a median below 50 ms on the current machine;
- fewer than 15 plugins are loaded at initial startup;
- interactive smoke checks cover completion, file search, live grep, explorer reveal, LSP attachment, format-on-save, and tmux navigation.

Performance measurements are comparative and must be recorded with the same Neovim binary, working directory, installed plugin state, and command before and after the migration.

## Scope Boundaries

This redesign does not:

- add debugging or integrated test-running;
- change the colorscheme or visual identity;
- upgrade Neovim to 0.12;
- migrate to the rewritten Tree-sitter `main` branch;
- redesign CodeCompanion prompts or adapters;
- remove useful lazy-loaded tools solely to minimize the lockfile;
- touch `.nvimlog` or unrelated user changes.
