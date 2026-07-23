local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  -- stylua: ignore
  vim.fn.system({ 'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

require('lazy').setup {
  spec = {
    { 'tpope/vim-sleuth', event = { 'BufReadPost', 'BufNewFile' } },
    { import = 'plugins.coding.completion' },
    { import = 'plugins.coding.copilot' },
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
        'spellfile',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
      },
    },
  },
}
