-- Prevent Netrw from showing up at beginning
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- Register project filetypes before lazy.nvim evaluates filetype-based triggers.
vim.filetype.add {
  extension = { mdx = 'mdx' },
  filename = {
    ['compose.yaml'] = 'yaml.docker-compose',
    ['compose.yml'] = 'yaml.docker-compose',
    ['docker-compose.yaml'] = 'yaml.docker-compose',
    ['docker-compose.yml'] = 'yaml.docker-compose',
  },
}
