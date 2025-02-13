-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    -- features = {
    --   large_buf = { size = 1024 * 256, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
    --   autopairs = true, -- enable autopairs at start
    --   cmp = true, -- enable completion at start
    --   diagnostics_mode = 3, -- diagnostic mode on start (0 = off, 1 = no signs/virtual text, 2 = no virtual text, 3 = on)
    --   highlighturl = true, -- highlight URLs at start
    --   notifications = true, -- enable notifications at start
    -- },
    -- -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    -- diagnostics = {
    --   virtual_text = true,
    --   underline = true,
    -- },
    -- -- vim options can be configured here
    -- options = {
    --   opt = { -- vim.opt.<key>
    --     relativenumber = true, -- sets vim.opt.relativenumber
    --     number = true, -- sets vim.opt.number
    --     spell = false, -- sets vim.opt.spell
    --     signcolumn = "yes", -- sets vim.opt.signcolumn to yes
    --     wrap = false, -- sets vim.opt.wrap
    --   },
    --   g = { -- vim.g.<key>
    --     -- configure global vim variables (vim.g)
    --     -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
    --     -- This can be found in the `lua/lazy_setup.lua` file
    --   },
    -- },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        -- second key is the lefthand side of the map

        -- navigate buffer tabs
        ["<S-K>"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["<S-J>"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },
        [";"] = { ":" },

        ["<leader>e"] = {
          "<cmd>NvimTreeToggle<cr>",
        },

        -- mappings seen under group name "Buffer"
        -- ["<Leader>bd"] = {
        --   function()
        --     require("astroui.status.heirline").buffer_picker(
        --       function(bufnr) require("astrocore.buffer").close(bufnr) end
        --     )
        --   end,
        --   desc = "Close buffer from tabline",
        -- },

        -- tables with just a `desc` key will be registered with which-key if it's installed
        -- this is useful for naming menus
        -- ["<Leader>b"] = { desc = "Buffers" },

        -- setting a mapping to false will disable it
        -- ["<C-S>"] = false,
      },
      t = {
        ["<C-X>"] = { "<C-\\><C-N>", desc = "Exit terminal mode" },
      },
    },
    sessions = {
      -- Configure auto saving
      autosave = {
        last = true, -- auto save last session
        cwd = true, -- auto save session for each working directory
      },
      -- Patterns to ignore when saving sessions
      ignore = {
        dirs = {}, -- working directories to ignore sessions in
        filetypes = { "gitcommit", "gitrebase" }, -- filetypes to ignore sessions
        buftypes = {}, -- buffer types to ignore sessions
      },
    },
  },
}
