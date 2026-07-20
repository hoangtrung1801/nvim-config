-- Prevent Netrw from showing up at beginning
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- Register MDX before lazy.nvim evaluates filetype-based plugin triggers.
vim.filetype.add { extension = { mdx = 'mdx' } }
