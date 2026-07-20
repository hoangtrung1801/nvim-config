# Fast and Convenient Neovim Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace overlapping and broken Neovim subsystems with a smaller, faster stack centered on blink.cmp, Snacks, native Neovim 0.11 LSP, and consolidated Mini modules.

**Architecture:** Lazy loads a minimal startup core and defers feature plugins by key, command, event, or filetype. A single `lua/config/languages.lua` registry drives LSP servers, Mason tools, Tree-sitter parsers, formatters, and linters; focused plugin files consume that registry without cross-spec option merging.

**Tech Stack:** Neovim 0.11.4, Lua, lazy.nvim, blink.cmp 1.x, snacks.nvim, nvim-lspconfig native `vim.lsp.config` API, Mason, Conform, nvim-lint, legacy nvim-treesitter `master`, mini.nvim, smart-splits.nvim.

## Global Constraints

- Optimize for maximum startup and runtime speed while preserving convenient keyboard-first UX.
- Fully support Lua, TypeScript/JavaScript, Astro, Python, Go, Docker/Compose, Tailwind/CSS, Markdown, and MDX.
- Do not add or retain integrated debugging or test-running.
- Keep Neovim at 0.11.4 and nvim-treesitter on legacy `master`.
- Preserve the existing colorscheme and familiar keybindings where practical.
- Never modify or remove the user-owned untracked `.nvimlog`.
- External tool checks and installation must not block ordinary startup.
- Final warm headless median must be below 50 ms with fewer than 15 initially loaded plugins.

---

## Final File Structure

### Create

- `lua/config/languages.lua` — single source of truth for servers, tools, parsers, formatters, and linters.
- `lua/plugins/coding/completion.lua` — blink.cmp specification and mappings.
- `lua/plugins/editor/smart-splits.lua` — Neovim/tmux navigation and resize mappings.
- `tests/helpers.lua` — shared headless assertion helpers.
- `tests/completion_spec.lua` — completion and Mini consolidation assertions.
- `tests/ux_spec.lua` — Snacks and navigation assertions.
- `tests/languages_spec.lua` — native LSP and language-registry assertions.
- `tests/tooling_spec.lua` — formatter, linter, parser, and native-fold assertions.
- `tests/plugin_graph_spec.lua` — final desired/removed plugin graph assertions.
- `scripts/benchmark-startup.sh` — repeatable warm-start benchmark.

### Rewrite

- `lua/lazy-init.lua` — one valid lazy.nvim setup table and reduced imports.
- `lua/options.lua` — native fold defaults and startup-safe options.
- `lua/keymaps.lua` — remove plugin-owned global mappings and avoid conflicts.
- `lua/plugins/coding/lspconfig.lua` — native Neovim 0.11 LSP configuration.
- `lua/plugins/coding/treesitter.lua` — unified parser list and deferred setup.
- `lua/plugins/editor/snacks.lua` — unified picker, explorer, UI, Git, and big-file UX.
- `lua/plugins/editor/mini.lua` — consolidated Mini modules.
- `lua/plugins/editor/leap.lua` — Leap-only targeted motion.
- `lua/plugins/formatting/conform.lua` — registry-driven formatting.
- `lua/plugins/linting/core.lua` — registry-driven linting with one-time missing-tool messages.
- `lua/plugins/languages/python.lua` — main-branch venv-selector with Snacks picker.
- `lua/plugins/languages/markdown.lua` — render-markdown only.
- `lua/plugins/ui/bufferline.lua` — MiniIcons-backed icons without nvim-web-devicons.
- `lua/health.lua` — required binary and language-tool health checks.

### Delete

- `lua/plugins/coding/autopairs.lua`
- `lua/plugins/coding/cmp.lua`
- `lua/plugins/coding/fold.lua`
- `lua/plugins/dap/core.lua`
- `lua/plugins/editor/fzf.lua`
- `lua/plugins/editor/indent-line.lua`
- `lua/plugins/editor/lazygit.lua`
- `lua/plugins/editor/neo-tree.lua`
- `lua/plugins/editor/tmux.lua`
- `lua/plugins/formatting/prettier.lua`
- `lua/plugins/languages/astro.lua`
- `lua/plugins/languages/docker.lua`
- `lua/plugins/languages/go.lua`
- `lua/plugins/languages/tailwind.lua`
- `lua/plugins/languages/typescript.lua`
- `lua/plugins/test/core.lua`
- `lua/plugins/ui/dressing.lua`
- `lua/plugins/util/mini-hipatterns.lua`

---

### Task 1: Replace completion and consolidate Mini modules

**Files:**

- Create: `tests/helpers.lua`
- Create: `tests/completion_spec.lua`
- Create: `lua/plugins/coding/completion.lua`
- Modify: `lua/plugins/editor/mini.lua`
- Modify: `lua/plugins/ui/bufferline.lua`
- Delete: `lua/plugins/coding/autopairs.lua`
- Delete: `lua/plugins/coding/cmp.lua`
- Delete: `lua/plugins/util/mini-hipatterns.lua`

**Interfaces:**

- Produces: Lazy plugin `blink.cmp` and `require('blink.cmp').get_lsp_capabilities()` for Task 3.
- Produces: `mini.ai`, `mini.icons`, `mini.move`, `mini.pairs`, `mini.statusline`, `mini.surround`, and `mini.hipatterns` from one `mini.nvim` checkout.
- Preserves: current completion navigation and acceptance keys.

- [ ] **Step 1: Write shared test helpers**

~~~lua
-- tests/helpers.lua
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
~~~

- [ ] **Step 2: Write the failing completion graph test**

~~~lua
-- tests/completion_spec.lua
local h = dofile(vim.fn.getcwd() .. '/tests/helpers.lua')
local failures = h.collect()
local plugins = h.plugins()

h.check(failures, plugins['blink.cmp'] ~= nil, 'blink.cmp must be installed')
h.check(failures, plugins['nvim-cmp'] == nil, 'nvim-cmp must be removed')
h.check(failures, plugins['LuaSnip'] == nil, 'LuaSnip must be removed')
h.check(failures, plugins['cmp-nvim-lsp'] == nil, 'cmp-nvim-lsp must be removed')
h.check(failures, plugins['cmp-path'] == nil, 'cmp-path must be removed')
h.check(failures, plugins['cmp_luasnip'] == nil, 'cmp_luasnip must be removed')
h.check(failures, plugins['nvim-autopairs'] == nil, 'nvim-autopairs must be removed')
h.check(failures, plugins['mini.hipatterns'] == nil, 'standalone mini.hipatterns must be removed')
h.check(failures, plugins['mini.icons'] == nil, 'standalone mini.icons must be removed')

h.finish(failures)
~~~

- [ ] **Step 3: Run the test and verify it fails for the current cmp stack**

Run:

~~~bash
nvim --headless -u ./init.lua -i NONE -n -l tests/completion_spec.lua
~~~

Expected: non-zero exit with `blink.cmp must be installed` and current completion plugins reported as not removed.

- [ ] **Step 4: Add blink.cmp with explicit familiar mappings**

~~~lua
-- lua/plugins/coding/completion.lua
return {
  {
    'saghen/blink.cmp',
    version = '1.*',
    event = 'InsertEnter',
    dependencies = {
      {
        'folke/lazydev.nvim',
        ft = 'lua',
        opts = {
          library = {
            { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
          },
        },
      },
    },
    opts = {
      keymap = {
        preset = 'none',
        ['<C-Space>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<C-e>'] = { 'hide', 'fallback' },
        ['<C-n>'] = { 'select_next', 'fallback' },
        ['<C-p>'] = { 'select_prev', 'fallback' },
        ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
        ['<C-y>'] = { 'select_and_accept' },
        ['<CR>'] = { 'accept', 'fallback' },
        ['<Tab>'] = { 'snippet_forward', 'select_next', 'fallback' },
        ['<S-Tab>'] = { 'snippet_backward', 'select_prev', 'fallback' },
      },
      appearance = {
        nerd_font_variant = 'mono',
      },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        ghost_text = { enabled = false },
        list = { selection = { preselect = false, auto_insert = false } },
      },
      signature = { enabled = true },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
        per_filetype = {
          lua = { inherit_defaults = true, 'lazydev' },
        },
        providers = {
          lazydev = {
            name = 'LazyDev',
            module = 'lazydev.integrations.blink',
            score_offset = 100,
          },
        },
      },
      fuzzy = {
        implementation = 'prefer_rust',
      },
    },
    opts_extend = { 'sources.default' },
  },
}
~~~

- [ ] **Step 5: Consolidate Mini setup into one deferred plugin**

Rewrite `lua/plugins/editor/mini.lua` so it configures all required modules from `nvim-mini/mini.nvim`:

~~~lua
return {
  {
    'nvim-mini/mini.nvim',
    event = 'VeryLazy',
    config = function()
      require('mini.ai').setup { n_lines = 500 }
      require('mini.icons').setup()
      require('mini.icons').mock_nvim_web_devicons()
      require('mini.pairs').setup()
      require('mini.hipatterns').setup {
        highlighters = {
          fixme = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
          hack = { pattern = '%f[%w]()HACK()%f[%W]', group = 'MiniHipatternsHack' },
          todo = { pattern = '%f[%w]()TODO()%f[%W]', group = 'MiniHipatternsTodo' },
          note = { pattern = '%f[%w]()NOTE()%f[%W]', group = 'MiniHipatternsNote' },
          hex_color = require('mini.hipatterns').gen_highlighter.hex_color(),
        },
      }
      require('mini.surround').setup {
        mappings = {
          add = 'gza',
          delete = 'gzd',
          find = 'gzf',
          find_left = 'gzF',
          highlight = 'gzh',
          replace = 'gzr',
          update_n_lines = 'gzn',
        },
      }
      require('mini.move').setup {
        mappings = {
          left = 'H',
          right = 'L',
          down = 'J',
          up = 'K',
          line_left = '',
          line_right = '',
          line_down = '',
          line_up = '',
        },
      }

      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = vim.g.have_nerd_font }
      statusline.section_location = function()
        return '%2l:%-2v'
      end
    end,
  },
}
~~~

In `lua/plugins/ui/bufferline.lua` replace the web-devicons dependency with:

~~~lua
dependencies = { 'nvim-mini/mini.nvim' },
~~~

- [ ] **Step 6: Delete the superseded completion and standalone Mini files**

Delete the three files listed for this task. Remove their imports from `lua/lazy-init.lua` temporarily; Task 5 will rewrite the full import table.

- [ ] **Step 7: Install blink and verify the completion test passes**

Run:

~~~bash
nvim --headless -u ./init.lua -i NONE -n '+Lazy! sync' +qa
nvim --headless -u ./init.lua -i NONE -n -l tests/completion_spec.lua
~~~

Expected: Lazy installs `blink.cmp` and removes orphaned completion plugins; the test exits 0.

- [ ] **Step 8: Commit**

~~~bash
git add lua/plugins/coding lua/plugins/editor/mini.lua lua/plugins/ui/bufferline.lua lua/plugins/util tests
git commit -m "perf: replace cmp stack with blink"
~~~

---

### Task 2: Unify picker, explorer, UI, and pane navigation

**Files:**

- Create: `tests/ux_spec.lua`
- Create: `lua/plugins/editor/smart-splits.lua`
- Rewrite: `lua/keymaps.lua`
- Rewrite: `lua/plugins/editor/snacks.lua`
- Rewrite: `lua/plugins/editor/leap.lua`
- Delete: `lua/plugins/editor/fzf.lua`
- Delete: `lua/plugins/editor/indent-line.lua`
- Delete: `lua/plugins/editor/lazygit.lua`
- Delete: `lua/plugins/editor/neo-tree.lua`
- Delete: `lua/plugins/editor/tmux.lua`
- Delete: `lua/plugins/ui/dressing.lua`

**Interfaces:**

- Produces: global `Snacks` modules used by picker, LSP, buffer, notification, and Markdown mappings.
- Produces: `Ctrl-h/j/k/l` movement and `Alt-h/j/k/l` resizing through `smart-splits.nvim`.
- Preserves: existing `<leader>f*` and `<leader>s*` search vocabulary.

- [ ] **Step 1: Write the failing UX graph and keymap test**

~~~lua
-- tests/ux_spec.lua
local h = dofile(vim.fn.getcwd() .. '/tests/helpers.lua')
local failures = h.collect()
local plugins = h.plugins()

for _, name in ipairs {
  'fzf-lua',
  'telescope.nvim',
  'neo-tree.nvim',
  'dressing.nvim',
  'lazygit.nvim',
  'indent-blankline.nvim',
  'tmux.nvim',
  'vim-tmux-navigator',
  'flit.nvim',
} do
  h.check(failures, plugins[name] == nil, name .. ' must be removed')
end

h.check(failures, plugins['snacks.nvim'] ~= nil, 'snacks.nvim must remain')
h.check(failures, plugins['smart-splits.nvim'] ~= nil, 'smart-splits.nvim must be installed')

for _, lhs in ipairs {
  '<leader>e',
  '<leader>ff',
  '<leader>fg',
  '<leader>fb',
  '<leader>sg',
  '<leader>ss',
  '<leader>sS',
  '<leader>wv',
  '<leader>ws',
  's',
} do
  local map = vim.fn.maparg(lhs, 'n', false, true)
  h.check(failures, type(map) == 'table' and map.desc ~= nil, lhs .. ' must be mapped')
end

h.finish(failures)
~~~

- [ ] **Step 2: Run the UX test and verify the overlapping graph fails**

Run:

~~~bash
nvim --headless -u ./init.lua -i NONE -n -l tests/ux_spec.lua
~~~

Expected: non-zero exit naming FZF, Telescope, Neo-tree, and tmux overlap.

- [ ] **Step 3: Rewrite Snacks as the unified UX layer**

~~~lua
-- lua/plugins/editor/snacks.lua
local picker = function(method, opts)
  return function()
    Snacks.picker[method](opts)
  end
end

return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      explorer = { enabled = true },
      indent = { enabled = true },
      input = { enabled = true },
      notifier = { enabled = true, timeout = 3000 },
      picker = {
        enabled = true,
        sources = {
          files = { hidden = true, ignored = false },
          grep = { hidden = true, ignored = false },
          explorer = { hidden = true, ignored = false, layout = { preset = 'sidebar', position = 'right' } },
        },
      },
      quickfile = { enabled = true },
      scope = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
    },
    keys = {
      { '<leader>e', function() Snacks.explorer() end, desc = 'Explorer' },
      { '<leader>,', picker 'buffers', desc = 'Switch Buffer' },
      { '<leader>fb', picker 'buffers', desc = 'Buffers' },
      { '<leader>ff', picker 'files', desc = 'Files' },
      { '<leader>p', picker 'files', desc = 'Find Files' },
      { '<leader>fg', picker 'git_files', desc = 'Git Files' },
      { '<leader>s"', picker 'registers', desc = 'Registers' },
      { '<leader>sa', picker 'autocmds', desc = 'Autocommands' },
      { '<leader>sb', picker 'lines', desc = 'Buffer Lines' },
      { '<leader>sc', picker 'command_history', desc = 'Command History' },
      { '<leader>sC', picker 'commands', desc = 'Commands' },
      { '<leader>sd', picker 'diagnostics_buffer', desc = 'Buffer Diagnostics' },
      { '<leader>sD', picker 'diagnostics', desc = 'Workspace Diagnostics' },
      { '<leader>sg', picker 'grep', desc = 'Grep' },
      { '<leader>sh', picker 'help', desc = 'Help Pages' },
      { '<leader>sH', picker 'highlights', desc = 'Highlight Groups' },
      { '<leader>sj', picker 'jumps', desc = 'Jumplist' },
      { '<leader>sk', picker 'keymaps', desc = 'Keymaps' },
      { '<leader>sl', picker 'loclist', desc = 'Location List' },
      { '<leader>sM', picker 'man', desc = 'Man Pages' },
      { '<leader>sm', picker 'marks', desc = 'Marks' },
      { '<leader>sq', picker 'qflist', desc = 'Quickfix List' },
      { '<leader>sR', picker 'resume', desc = 'Resume' },
      { '<leader>ss', picker 'lsp_symbols', desc = 'Document Symbols' },
      { '<leader>sS', picker 'lsp_workspace_symbols', desc = 'Workspace Symbols' },
      { '<leader>gg', function() Snacks.lazygit() end, desc = 'Lazygit' },
    },
    init = function()
      vim.api.nvim_create_autocmd('User', {
        pattern = 'VeryLazy',
        callback = function()
          _G.dd = function(...)
            Snacks.debug.inspect(...)
          end
          vim.print = _G.dd
        end,
      })
    end,
  },
}
~~~

- [ ] **Step 4: Add one smart-splits integration**

~~~lua
-- lua/plugins/editor/smart-splits.lua
return {
  {
    'mrjones2014/smart-splits.nvim',
    version = '>=2.0.0',
    lazy = false,
    opts = {
      at_edge = 'stop',
      default_amount = 3,
      ignored_filetypes = { 'snacks_picker_list', 'snacks_picker_input' },
    },
    keys = {
      { '<C-h>', function() require('smart-splits').move_cursor_left() end, desc = 'Move Left' },
      { '<C-j>', function() require('smart-splits').move_cursor_down() end, desc = 'Move Down' },
      { '<C-k>', function() require('smart-splits').move_cursor_up() end, desc = 'Move Up' },
      { '<C-l>', function() require('smart-splits').move_cursor_right() end, desc = 'Move Right' },
      { '<C-\\>', function() require('smart-splits').move_cursor_previous() end, desc = 'Move Previous' },
      { '<A-h>', function() require('smart-splits').resize_left() end, desc = 'Resize Left' },
      { '<A-j>', function() require('smart-splits').resize_down() end, desc = 'Resize Down' },
      { '<A-k>', function() require('smart-splits').resize_up() end, desc = 'Resize Up' },
      { '<A-l>', function() require('smart-splits').resize_right() end, desc = 'Resize Right' },
    },
  },
}
~~~

`smart-splits.nvim` must remain eager because its tmux integration sets `@pane-is-vim` during startup.

- [ ] **Step 5: Reduce Leap to targeted motion only**

~~~lua
-- lua/plugins/editor/leap.lua
return {
  {
    'ggandor/leap.nvim',
    keys = {
      { 's', mode = { 'n', 'x', 'o' }, function() require('leap').leap { target_windows = { vim.api.nvim_get_current_win() } } end, desc = 'Leap Forward' },
      { 'S', mode = { 'n', 'x', 'o' }, function() require('leap').leap { backward = true, target_windows = { vim.api.nvim_get_current_win() } } end, desc = 'Leap Backward' },
      { 'gs', mode = { 'n', 'x', 'o' }, function() require('leap').leap { target_windows = require('leap.util').get_enterable_windows() } end, desc = 'Leap Windows' },
    },
  },
}
~~~

- [ ] **Step 6: Remove the split-key conflict from global keymaps**

In `lua/keymaps.lua`, replace the current `ss` and `sv` mappings, which are unreachable once Leap owns `s`, with an explicit window group:

~~~lua
keymap.set('n', '<leader>wv', '<cmd>vsplit<cr>', { desc = 'Split Vertical' })
keymap.set('n', '<leader>ws', '<cmd>split<cr>', { desc = 'Split Horizontal' })
keymap.set('n', '<leader>wq', '<cmd>close<cr>', { desc = 'Close Window' })
~~~

Add this Which-key group in `lua/plugins/editor/which-key.lua`:

~~~lua
{
  '<leader>w',
  group = 'Windows',
  icon = { icon = '', color = 'cyan' },
},
~~~

- [ ] **Step 7: Delete the superseded UX files and remove their imports**

Delete all files listed for this task. Do not touch `lua/plugins/editor/grug-far.lua`, `lua/plugins/editor/gitsigns.lua`, `lua/plugins/editor/overseer.lua`, or `lua/plugins/editor/which-key.lua`.

- [ ] **Step 8: Sync and verify the UX test**

Run:

~~~bash
nvim --headless -u ./init.lua -i NONE -n '+Lazy! sync' +qa
nvim --headless -u ./init.lua -i NONE -n -l tests/ux_spec.lua
~~~

Expected: `smart-splits.nvim` installs, redundant plugins leave the graph, and the test exits 0.

- [ ] **Step 9: Commit**

~~~bash
git add lua/keymaps.lua lua/plugins/editor lua/plugins/ui tests/ux_spec.lua lazy-lock.json
git commit -m "perf: consolidate navigation with snacks"
~~~

---

### Task 3: Centralize language definitions and migrate to native LSP

**Files:**

- Create: `tests/languages_spec.lua`
- Create: `lua/config/languages.lua`
- Rewrite: `lua/plugins/coding/lspconfig.lua`
- Rewrite: `lua/plugins/languages/python.lua`
- Delete: `lua/plugins/languages/astro.lua`
- Delete: `lua/plugins/languages/docker.lua`
- Delete: `lua/plugins/languages/go.lua`
- Delete: `lua/plugins/languages/tailwind.lua`
- Delete: `lua/plugins/languages/typescript.lua`

**Interfaces:**

- Produces: `require('config.languages')` with `servers`, `tools`, `parsers`, `formatters_by_ft`, and `linters_by_ft`.
- Consumes: `require('blink.cmp').get_lsp_capabilities()` from Task 1.
- Produces: native `vim.lsp.config.<server>` entries and automatic activation for every server.

- [ ] **Step 1: Write the failing native-LSP test**

~~~lua
-- tests/languages_spec.lua
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
    h.check(failures, registry.servers[name] ~= nil, name .. ' missing from registry')
    h.check(failures, type(vim.lsp.config[name]) == 'table', name .. ' missing from vim.lsp.config')
  end
end

h.finish(failures)
~~~

- [ ] **Step 2: Run the language test and verify the registry is missing**

Run:

~~~bash
nvim --headless -u ./init.lua -i NONE -n -l tests/languages_spec.lua
~~~

Expected: non-zero exit with `config.languages must load`.

- [ ] **Step 3: Create the single language registry**

Create `lua/config/languages.lua` with the following structure and values:

~~~lua
local mason = vim.fn.stdpath 'data' .. '/mason'
local prettier = { 'prettierd', 'prettier', stop_after_first = true }

return {
  servers = {
    lua_ls = {
      settings = {
        Lua = {
          completion = { callSnippet = 'Replace' },
          workspace = { checkThirdParty = false },
        },
      },
    },
    vtsls = {
      filetypes = {
        'javascript',
        'javascriptreact',
        'javascript.jsx',
        'typescript',
        'typescriptreact',
        'typescript.tsx',
      },
      settings = {
        complete_function_calls = true,
        vtsls = {
          enableMoveToFileCodeAction = true,
          autoUseWorkspaceTsdk = true,
          experimental = {
            maxInlayHintLength = 30,
            completion = { enableServerSideFuzzyMatch = true },
          },
          tsserver = {
            globalPlugins = {
              {
                name = '@astrojs/ts-plugin',
                location = mason
                  .. '/packages/astro-language-server/node_modules/@astrojs/ts-plugin',
                enableForWorkspaceTypeScriptVersions = true,
              },
            },
          },
        },
        typescript = {
          updateImportsOnFileMove = { enabled = 'always' },
          suggest = { completeFunctionCalls = true },
          inlayHints = {
            enumMemberValues = { enabled = true },
            functionLikeReturnTypes = { enabled = true },
            parameterNames = { enabled = 'literals' },
            parameterTypes = { enabled = true },
            propertyDeclarationTypes = { enabled = true },
            variableTypes = { enabled = false },
          },
        },
      },
    },
    eslint = {
      settings = {
        workingDirectories = { mode = 'auto' },
      },
    },
    astro = {},
    pyright = {},
    ruff = {
      init_options = { settings = { logLevel = 'error' } },
    },
    gopls = {
      settings = {
        gopls = {
          gofumpt = true,
          completeUnimported = true,
          usePlaceholders = true,
          staticcheck = true,
          semanticTokens = true,
          analyses = {
            fieldalignment = true,
            nilness = true,
            unusedparams = true,
            unusedwrite = true,
            useany = true,
          },
          codelenses = {
            generate = true,
            regenerate_cgo = true,
            run_govulncheck = true,
            test = true,
            tidy = true,
            upgrade_dependency = true,
            vendor = true,
          },
          hints = {
            assignVariableTypes = true,
            compositeLiteralFields = true,
            compositeLiteralTypes = true,
            constantValues = true,
            functionTypeParameters = true,
            parameterNames = true,
            rangeVariableTypes = true,
          },
          directoryFilters = {
            '-.git',
            '-.idea',
            '-.vscode',
            '-.vscode-test',
            '-node_modules',
          },
        },
      },
    },
    dockerls = {},
    docker_compose_language_service = {},
    tailwindcss = {
      filetypes = {
        'astro',
        'css',
        'html',
        'javascript',
        'javascriptreact',
        'svelte',
        'typescript',
        'typescriptreact',
        'vue',
      },
      settings = {
        tailwindCSS = {
          includeLanguages = {
            elixir = 'html-eex',
            eelixir = 'html-eex',
            heex = 'html-eex',
          },
        },
      },
    },
    cssls = {},
    marksman = {},
  },
  tools = {
    'astro-language-server',
    'css-lsp',
    'docker-compose-language-service',
    'dockerfile-language-server',
    'eslint-lsp',
    'gofumpt',
    'goimports',
    'gopls',
    'hadolint',
    'lua-language-server',
    'markdown-toc',
    'markdownlint-cli2',
    'marksman',
    'prettier',
    'prettierd',
    'pyright',
    'ruff',
    'stylua',
    'tailwindcss-language-server',
    'vtsls',
  },
  parsers = {
    'astro',
    'bash',
    'c',
    'css',
    'diff',
    'dockerfile',
    'go',
    'gomod',
    'gosum',
    'gowork',
    'html',
    'javascript',
    'json',
    'jsonc',
    'lua',
    'luadoc',
    'markdown',
    'markdown_inline',
    'ninja',
    'python',
    'query',
    'rst',
    'tsx',
    'typescript',
    'vim',
    'vimdoc',
    'yaml',
  },
  formatters_by_ft = {
    astro = prettier,
    css = prettier,
    graphql = prettier,
    handlebars = prettier,
    html = prettier,
    javascript = prettier,
    javascriptreact = prettier,
    json = prettier,
    jsonc = prettier,
    less = prettier,
    lua = { 'stylua' },
    markdown = prettier,
    ['markdown.mdx'] = prettier,
    python = { 'ruff_organize_imports', 'ruff_format' },
    scss = prettier,
    typescript = prettier,
    typescriptreact = prettier,
    vue = prettier,
    yaml = prettier,
    go = { 'goimports', 'gofumpt' },
  },
  linters_by_ft = {
    dockerfile = { 'hadolint' },
    markdown = { 'markdownlint-cli2' },
    ['markdown.mdx'] = { 'markdownlint-cli2' },
  },
}
~~~

- [ ] **Step 4: Rewrite LSP setup around Neovim 0.11 APIs**

The final `lua/plugins/coding/lspconfig.lua` must:

1. load on `BufReadPre`/`BufNewFile`;
2. configure Mason and mason-tool-installer from `registry.tools`;
3. merge blink capabilities through `vim.lsp.config('*', ...)`;
4. call `vim.lsp.config(name, config)` for every registry server;
5. call `vim.lsp.enable(vim.tbl_keys(registry.servers))`;
6. create one `LspAttach` group for keymaps and server-specific behavior.

Use this implementation:

~~~lua
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
      local highlight_group = vim.api.nvim_create_augroup(
        'config-lsp-highlight',
        { clear = true }
      )
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

          map('gd', function() Snacks.picker.lsp_definitions() end, 'Goto Definition')
          map('gr', function() Snacks.picker.lsp_references() end, 'References')
          map('gI', function() Snacks.picker.lsp_implementations() end, 'Goto Implementation')
          map('gy', function() Snacks.picker.lsp_type_definitions() end, 'Goto Type Definition')
          map('gD', vim.lsp.buf.declaration, 'Goto Declaration')
          map('<leader>ca', vim.lsp.buf.code_action, 'Code Action', { 'n', 'x' })
          map(']]', function() Snacks.words.jump(vim.v.count1) end, 'Next Reference')
          map('[[', function() Snacks.words.jump(-vim.v.count1) end, 'Previous Reference')

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
            map('<leader>co', lsp_action 'source.organizeImports', 'Organize Imports')
            map('<leader>cM', lsp_action 'source.addMissingImports.ts', 'Add Missing Imports')
            map('<leader>cu', lsp_action 'source.removeUnused.ts', 'Remove Unused Imports')
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
~~~

- [ ] **Step 5: Move Python environment selection to the current Snacks backend**

~~~lua
-- lua/plugins/languages/python.lua
return {
  {
    'linux-cultist/venv-selector.nvim',
    branch = 'main',
    ft = 'python',
    dependencies = { 'folke/snacks.nvim' },
    opts = {
      options = {
        picker = 'snacks',
        cached_venv_automatic_activation = true,
        require_lsp_activation = true,
      },
    },
    keys = {
      { '<leader>vs', '<cmd>VenvSelect<cr>', desc = 'Select Python Environment' },
    },
  },
}
~~~

Cached environments activate automatically. Remove the old `<leader>vc` mapping because the current plugin exposes `VenvSelectCache` only when automatic cache activation is disabled.

- [ ] **Step 6: Delete the old language merge files and verify native configs**

Delete the five language files listed for this task. Run:

~~~bash
nvim --headless -u ./init.lua -i NONE -n -l tests/languages_spec.lua
nvim --headless -u ./init.lua -i NONE -n '+checkhealth vim.lsp' +qa
~~~

Expected: language test exits 0; health output contains no deprecated local setup call.

- [ ] **Step 7: Commit**

~~~bash
git add lua/config lua/plugins/coding/lspconfig.lua lua/plugins/languages tests/languages_spec.lua
git commit -m "feat: configure languages with native lsp"
~~~

---

### Task 4: Centralize formatting, linting, parsers, and folding

**Files:**

- Create: `tests/tooling_spec.lua`
- Rewrite: `lua/plugins/formatting/conform.lua`
- Rewrite: `lua/plugins/linting/core.lua`
- Rewrite: `lua/plugins/coding/treesitter.lua`
- Modify: `lua/options.lua`
- Rewrite: `lua/plugins/languages/markdown.lua`
- Delete: `lua/plugins/formatting/prettier.lua`
- Delete: `lua/plugins/coding/fold.lua`

**Interfaces:**

- Consumes: `config.languages.formatters_by_ft`, `linters_by_ft`, and `parsers`.
- Produces: `ConformInfo`, `<leader>cf`, format-on-save, lint autocommands, and native Tree-sitter folds.

- [ ] **Step 1: Write the failing tooling test**

~~~lua
-- tests/tooling_spec.lua
local h = dofile(vim.fn.getcwd() .. '/tests/helpers.lua')
local failures = h.collect()
local registry = require 'config.languages'

require('lazy').load { plugins = { 'conform.nvim', 'nvim-lint', 'nvim-treesitter' } }

local conform = require 'conform'
local lint = require 'lint'
h.check(failures, vim.deep_equal(conform.formatters_by_ft, registry.formatters_by_ft), 'Conform must use the registry')
h.check(failures, vim.deep_equal(lint.linters_by_ft, registry.linters_by_ft), 'nvim-lint must use the registry')
h.check(failures, vim.o.foldmethod == 'expr', 'foldmethod must use native expr folding')
h.check(failures, vim.o.foldexpr == 'v:lua.vim.treesitter.foldexpr()', 'foldexpr must use native Tree-sitter')

h.finish(failures)
~~~

- [ ] **Step 2: Run the tooling test and verify current scattered configuration fails**

Run:

~~~bash
nvim --headless -u ./init.lua -i NONE -n -l tests/tooling_spec.lua
~~~

Expected: non-zero exit for formatter, linter, and folding mismatches.

- [ ] **Step 3: Rewrite Conform around the registry**

~~~lua
-- lua/plugins/formatting/conform.lua
return {
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>cf',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = { 'n', 'x' },
        desc = 'Format',
      },
    },
    opts = function()
      return {
        formatters_by_ft = require('config.languages').formatters_by_ft,
        default_format_opts = { lsp_format = 'fallback' },
        format_on_save = function(bufnr)
          if vim.g.disable_autoformat
            or vim.b[bufnr].disable_autoformat
            or vim.bo[bufnr].filetype == 'bigfile'
          then
            return
          end
          return { timeout_ms = 2000, lsp_format = 'fallback' }
        end,
      }
    end,
  },
}
~~~

- [ ] **Step 4: Rewrite linting with one-time missing-tool notifications**

~~~lua
-- lua/plugins/linting/core.lua
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

      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = vim.api.nvim_create_augroup('config-lint', { clear = true }),
        callback = run,
      })
    end,
  },
}
~~~

- [ ] **Step 5: Unify Tree-sitter parsers and use native folds**

~~~lua
-- lua/plugins/coding/treesitter.lua
return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'master',
    event = { 'BufReadPost', 'BufNewFile' },
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    opts = function()
      return {
        ensure_installed = require('config.languages').parsers,
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = { 'ruby' },
        },
        indent = { enable = true, disable = { 'ruby' } },
      }
    end,
  },
}
~~~

Add these options to `lua/options.lua`:

~~~lua
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true
vim.opt.fillchars:append {
  fold = ' ',
  foldopen = '',
  foldsep = ' ',
  foldclose = '',
}
~~~

- [ ] **Step 6: Preserve only Markdown UI behavior**

Rewrite `lua/plugins/languages/markdown.lua` to contain only the lazy-loaded render-markdown specification. Formatting, linting, Mason tools, and Marksman come exclusively from `config.languages`:

~~~lua
return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { 'markdown', 'markdown.mdx' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {
      file_types = { 'markdown', 'markdown.mdx' },
      code = { sign = false, width = 'block', right_pad = 1 },
      heading = { sign = false, icons = {} },
      checkbox = { enabled = false },
    },
    config = function(_, opts)
      require('render-markdown').setup(opts)
      Snacks.toggle {
        name = 'Render Markdown',
        get = function()
          return require('render-markdown.state').enabled
        end,
        set = function(enabled)
          local render = require 'render-markdown'
          if enabled then
            render.enable()
          else
            render.disable()
          end
        end,
      }:map '<leader>um'
    end,
  },
}
~~~

- [ ] **Step 7: Delete formatter/fold duplicates and verify tooling**

Delete `lua/plugins/formatting/prettier.lua` and `lua/plugins/coding/fold.lua`. Run:

~~~bash
nvim --headless -u ./init.lua -i NONE -n -l tests/tooling_spec.lua
~~~

Expected: exits 0.

- [ ] **Step 8: Commit**

~~~bash
git add lua/config lua/options.lua lua/plugins/coding lua/plugins/formatting lua/plugins/languages/markdown.lua lua/plugins/linting tests/tooling_spec.lua
git commit -m "perf: centralize language tooling"
~~~

---

### Task 5: Remove debug/test subsystems and normalize lazy loading

**Files:**

- Create: `tests/plugin_graph_spec.lua`
- Rewrite: `lua/lazy-init.lua`
- Modify: `lua/plugins/editor/gitsigns.lua`
- Modify: `lua/plugins/editor/which-key.lua`
- Modify: `lua/plugins/languages/mdx.lua`
- Modify: `lua/health.lua`
- Delete: `lua/plugins/dap/core.lua`
- Delete: `lua/plugins/test/core.lua`

**Interfaces:**

- Produces: final plugin graph with explicit load triggers.
- Preserves: all approved editing and navigation tools.

- [ ] **Step 1: Write the final graph test**

~~~lua
-- tests/plugin_graph_spec.lua
local h = dofile(vim.fn.getcwd() .. '/tests/helpers.lua')
local failures = h.collect()
local plugins = h.plugins()

local required = {
  'blink.cmp',
  'bufferline.nvim',
  'codecompanion.nvim',
  'conform.nvim',
  'gitsigns.nvim',
  'grug-far.nvim',
  'lazy.nvim',
  'leap.nvim',
  'mini.nvim',
  'nvim-lint',
  'nvim-lspconfig',
  'nvim-treesitter',
  'overseer.nvim',
  'render-markdown.nvim',
  'smart-splits.nvim',
  'snacks.nvim',
  'trouble.nvim',
  'venv-selector.nvim',
  'which-key.nvim',
}

local removed = {
  'LuaSnip',
  'cmp-nvim-lsp',
  'cmp-path',
  'cmp_luasnip',
  'dressing.nvim',
  'flit.nvim',
  'fzf-lua',
  'lazygit.nvim',
  'mason-lspconfig.nvim',
  'mason-nvim-dap.nvim',
  'neo-tree.nvim',
  'neotest',
  'nvim-autopairs',
  'nvim-cmp',
  'nvim-dap',
  'nvim-ufo',
  'nvim-web-devicons',
  'promise-async',
  'telescope.nvim',
  'tmux.nvim',
  'vim-repeat',
  'vim-tmux-navigator',
}

for _, name in ipairs(required) do
  h.check(failures, plugins[name] ~= nil, name .. ' must remain')
end
for _, name in ipairs(removed) do
  h.check(failures, plugins[name] == nil, name .. ' must be removed')
end

h.finish(failures)
~~~

- [ ] **Step 2: Run the graph test and verify DAP/test plugins still fail**

Run:

~~~bash
nvim --headless -u ./init.lua -i NONE -n -l tests/plugin_graph_spec.lua
~~~

Expected: non-zero exit until debug/test imports and obsolete plugins are removed.

- [ ] **Step 3: Rewrite lazy.nvim setup as one configuration table**

Keep the current bootstrap, then call `require('lazy').setup` once with this structure:

~~~lua
require('lazy').setup {
  spec = {
    { 'tpope/vim-sleuth', event = { 'BufReadPost', 'BufNewFile' } },
    { import = 'plugins.coding.completion' },
    { import = 'plugins.coding.codecompanion' },
    { import = 'plugins.coding.inc-rename' },
    { import = 'plugins.coding.lspconfig' },
    { import = 'plugins.coding.todo-comments' },
    { import = 'plugins.coding.treesitter' },
    { import = 'plugins.coding.trouble' },
    { import = 'plugins.editor.gitsigns' },
    { import = 'plugins.editor.grug-far' },
    { import = 'plugins.editor.leap' },
    { import = 'plugins.editor.mini' },
    { import = 'plugins.editor.overseer' },
    { import = 'plugins.editor.smart-splits' },
    { import = 'plugins.editor.snacks' },
    { import = 'plugins.editor.which-key' },
    { import = 'plugins.formatting.conform' },
    { import = 'plugins.languages.markdown' },
    { import = 'plugins.languages.mdx' },
    { import = 'plugins.languages.python' },
    { import = 'plugins.linting.core' },
    { import = 'plugins.ui.bufferline' },
    { import = 'plugins.ui.colorscheme' },
    { import = 'plugins.ui.treesitter-context' },
  },
  defaults = { lazy = true },
  install = { colorscheme = { 'cyberdream' } },
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
  performance = {
    rtp = {
      disabled_plugins = {
        'gzip',
        'matchit',
        'matchparen',
        'netrwPlugin',
        'shada',
        'spellfile',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
      },
    },
  },
}
~~~

Do not disable core providers needed by configured workflows. In particular, verify whether disabling `shada` breaks MRU behavior before retaining that entry; remove it from `disabled_plugins` if it does.

- [ ] **Step 4: Give retained plugins explicit lazy triggers**

- Set Gitsigns to `event = { 'BufReadPre', 'BufNewFile' }`.
- Set Which-key to `event = 'VeryLazy'`.
- Set MDX to `ft = { 'mdx', 'markdown.mdx' }`.
- Keep colorscheme and Snacks eager.
- Keep smart-splits eager for tmux state.
- Keep everything else command-, key-, filetype-, or event-loaded.

- [ ] **Step 5: Remove DAP and neotest files**

Delete `lua/plugins/dap/core.lua` and `lua/plugins/test/core.lua`. Remove all DAP statusline logic, DAP key groups, debug adapters, and test keymaps. Remove the Debug and Test groups from Which-key if no remaining mappings use them.

- [ ] **Step 6: Update health checks**

Extend `lua/health.lua` so `check_external_reqs` checks:

~~~lua
for _, exe in ipairs { 'git', 'make', 'unzip', 'rg', 'fd' } do
~~~

Add an informational note that `:MasonToolsInstall` installs language executables and `:checkhealth vim.lsp` diagnoses server activation.

Use these exact health messages after `check_external_reqs()`:

~~~lua
vim.health.info 'Run :MasonToolsInstall to install or update configured language tools.'
vim.health.info 'Run :checkhealth vim.lsp to diagnose language-server activation.'
~~~

- [ ] **Step 7: Sync and verify the final graph**

Run:

~~~bash
nvim --headless -u ./init.lua -i NONE -n '+Lazy! sync' +qa
nvim --headless -u ./init.lua -i NONE -n -l tests/plugin_graph_spec.lua
~~~

Expected: test exits 0 and lockfile contains no removed plugin.

- [ ] **Step 8: Commit**

~~~bash
git add lua/lazy-init.lua lua/health.lua lua/plugins lazy-lock.json tests/plugin_graph_spec.lua
git commit -m "perf: remove unused debug and test stacks"
~~~

---

### Task 6: Full verification and startup benchmark

**Files:**

- Create: `scripts/benchmark-startup.sh`
- Modify only if verification finds a scoped issue: files changed in Tasks 1–5.

**Interfaces:**

- Consumes all smoke tests.
- Produces repeatable startup measurements and final acceptance evidence.

- [ ] **Step 1: Add a deterministic five-run benchmark script**

~~~bash
#!/usr/bin/env bash
set -euo pipefail

config_dir="${1:-$PWD}"
results_dir="${TMPDIR:-/tmp}/nvim-startup-benchmark"
mkdir -p "$results_dir"

for run in 1 2 3 4 5; do
  nvim --headless -u "$config_dir/init.lua" -i NONE -n \
    --startuptime "$results_dir/run-$run.log" +qa
done

awk '/NVIM STARTED/ { print $1 }' "$results_dir"/run-*.log | sort -n
~~~

- [ ] **Step 2: Run every headless test**

Run:

~~~bash
for test in tests/*_spec.lua; do
  nvim --headless -u ./init.lua -i NONE -n -l "$test"
done
~~~

Expected: every command exits 0 with no error output.

- [ ] **Step 3: Verify normal startup and resolved load count**

Run:

~~~bash
nvim --headless -u ./init.lua -i NONE -n \
  '+lua local s=require("lazy").stats(); print(vim.json.encode(s))' +qa
~~~

Expected: no startup errors and `loaded` is less than 15 at the initial measurement point.

- [ ] **Step 4: Verify no deprecated local LSP setup remains**

Run:

~~~bash
rg -n "require\\(['\"]lspconfig|server_configurations|\\.setup\\(server|ruff_lsp|tsserver" lua
nvim --headless -u ./init.lua -i NONE -n '+checkhealth vim.lsp' +qa
~~~

Expected: ripgrep finds no deprecated local setup pattern; health output reports native configurations without local deprecation warnings.

- [ ] **Step 5: Benchmark startup**

Run:

~~~bash
chmod +x scripts/benchmark-startup.sh
scripts/benchmark-startup.sh
~~~

Expected: five sorted times with a median below 50 ms. Record the five values and median in the commit message body or final handoff.

- [ ] **Step 6: Run interactive smoke checks**

Open representative Lua, TypeScript, Astro, Python, Go, Dockerfile, Tailwind/CSS, Markdown, and MDX files. For the relevant buffers verify:

- blink completion opens, navigates, accepts, and expands native snippets;
- `gd`/`gr` and `<leader>ss` use Snacks pickers;
- `<leader>e` opens the explorer and reveals the current context;
- `<leader>ff` and `<leader>sg` search successfully;
- each language attaches the intended LSP clients;
- format-on-save invokes the intended formatter;
- Python `<leader>vs` uses the Snacks picker;
- `Ctrl-h/j/k/l` traverses Neovim and tmux panes;
- no large-file buffer enables expensive features.

- [ ] **Step 7: Inspect user changes and diff hygiene**

Run:

~~~bash
git status --short
git diff --check
git diff --stat HEAD~5..HEAD
~~~

Expected: `.nvimlog` remains untracked and untouched; no whitespace errors; only scoped config, tests, docs, script, and lockfile changes appear.

- [ ] **Step 8: Commit final verification support**

~~~bash
git add scripts/benchmark-startup.sh
git commit -m "test: add Neovim startup benchmark"
~~~

---

## Plan Self-Review Checklist

- Every approved language has an explicit server or parsing/rendering path.
- Every removed plugin is covered by a graph assertion.
- All new plugins have exact lazy.nvim specifications and load triggers.
- Completion, picker, LSP, formatting, linting, and folding each have a failing-first headless assertion.
- DAP and neotest are removed without replacement.
- Tree-sitter stays on `master` for Neovim 0.11.4.
- The `.nvimlog` exclusion is repeated in verification.
- No step uses placeholder implementation language.
