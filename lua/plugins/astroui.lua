-- AstroUI provides the basis for configuring the AstroNvim User Interface
-- Configuration documentation can be found with `:h astroui`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astroui",
  ---@type AstroUIOpts
  opts = {
    -- change colorscheme
    -- colorscheme = "nord",
    colorscheme = "nord",
    -- AstroUI allows you to easily modify highlight groups easily for any and all colorschemes
    highlights = {
      init = { -- this table overrides highlights in all themes
        -- Normal = { bg = "#000000" },
        Normal = { bg = "none" },
        SignColumn = { bg = "none" },
        FoldColumn = { bg = "none" },
        NormalFloat = { bg = "none" },
        NormalNC = { bg = "none" },
        NormalSB = { bg = "none" },
        FloatBorder = { bg = "none" },
        FloatTitle = { fg = "#F2F3F5", bg = "none" },
        -- WinBar
        WinBar = { bg = "none" },
        WinSeparator = { fg = "#F2F3F5", bg = "none" },
        WinBarNC = { bg = "none" },
        WhichKeyFloat = { bg = "none" },
        -- Telescope
        TelescopeBorder = { bg = "none" },
        TelescopePromptTitle = { bg = "none" },
        TelescopePromptBorder = { bg = "none" },
        TelescopeNormal = { bg = "none" },
        -- Diagnosis
        DiagnosticVirtualTextHint = { fg = "#F2F3F5", bg = "none" },
        DiagnosticVirtualTextWarn = { fg = "#e0af68", bg = "none" },
        DiagnosticVirtualTextInfo = { fg = "#9ece6a", bg = "none" },
        DiagnosticVirtualTextError = { fg = "#bd2c00", bg = "none" },
        -- NeoTree
        NeoTreeNormal = { bg = "none" },
        NeoTreeNormalNC = { bg = "none" },
        NeoTreeTabInactive = { bg = "none" },
        NeoTreeTabSeperatorActive = { fg = "#F2F3F5", bg = "none" },
        NeoTreeTabSeperatorInactive = { fg = "#F2F3F5", bg = "none" },
        NvimTreeTabSeperatorActive = { fg = "#F2F3F5", bg = "none" },
        NvimTreeTabSeperatorInactive = { fg = "#F2F3F5", bg = "none" },
        MiniTabLineFill = { fg = "#F2F3F5", bg = "none" },
        -- Spectre
        DiffChange = { fg = "#F2F3F5", bg = "#050a30" },
        DiffDelete = { fg = "#F2F3F5", bg = "#bd2c00" },
        -- StatusLine
        StatusLine = { fg = "#F2F3F5", bg = "none" },
        StatusLineNC = { fg = "#F2F3F5", bg = "none" },
        StatusLineTerm = { fg = "#F2F3F5", bg = "none" },
        StatusLineTermNC = { fg = "#F2F3F5", bg = "none" },
        VertSplit = { fg = "#F2F3F5", bg = "none" },
        -- QuickFixLine
        QuickFixLine = { bg = "none" },
        -- TabLine
        TabLine = { bg = "none" },
        TabLineSel = { bg = "none" },
        TabLineFill = { bg = "none" },
        -- Cursor
        CursorLineNr = { bg = "none" },
        CursorLine = { bg = "none" },
        ColorColumn = { bg = "none" },
        -- Search
        Search = { fg = "red" },
        IncSearch = { fg = "red" },
        -- Pmenu
        -- Pmenu = { bg = "none" },
        -- PmenuSel = { bg = "none" },
        -- PmenuSbar = { bg = "none" },
        -- PmenuThumb = { bg = "none" },
        -- Notifications
        NotifyINFOBody = { bg = "none" },
        NotifyWARNBody = { bg = "none" },
        NotifyERRORBody = { bg = "none" },
        NotifyDEBUGBody = { bg = "none" },
        NotifyTRACEBody = { bg = "none" },
        NotifyINFOBorder = { bg = "none" },
        NotifyWARNBorder = { bg = "none" },
        NotifyERRORBorder = { bg = "none" },
        NotifyDEBUGBorder = { bg = "none" },
        NotifyTRACEBorder = { bg = "none" },
        NotifyBackground = { bg = "#000000" },
      },
      astrodark = { -- a table of overrides/changes when applying the astrotheme theme
        -- Normal = { bg = "#000000" },
      },
    },
    -- Icons can be configured throughout the interface
    icons = {
      -- configure the loading of the lsp in the status line
      LSPLoading1 = "⠋",
      LSPLoading2 = "⠙",
      LSPLoading3 = "⠹",
      LSPLoading4 = "⠸",
      LSPLoading5 = "⠼",
      LSPLoading6 = "⠴",
      LSPLoading7 = "⠦",
      LSPLoading8 = "⠧",
      LSPLoading9 = "⠇",
      LSPLoading10 = "⠏",
    },
    -- Configuration options for the AstroNvim lines and bars built with the `status` API.
    -- status = {
    --   -- Configure attributes of components defined in the `status` API. Check the AstroNvim documentation for a complete list of color names, this applies to colors that have `_fg` and/or `_bg` names with the suffix removed (ex. `git_branch_fg` as attributes from `git_branch`).
    --   attributes = {
    --     git_branch = { bold = true },
    --   },
    --   -- Configure colors of components defined in the `status` API. Check the AstroNvim documentation for a complete list of color names.
    --   colors = {
    --     git_branch_fg = "#ABCDEF",
    --   },
    --   -- Configure which icons that are highlighted based on context
    --   icon_highlights = {
    --     -- enable or disable breadcrumb icon highlighting
    --     breadcrumbs = false,
    --     -- Enable or disable the highlighting of filetype icons both in the statusline and tabline
    --     file_icon = {
    --       tabline = function(self) return self.is_active or self.is_visible end,
    --       statusline = true,
    --     },
    --   },
    --   -- Configure characters used as separators for various elements
    --   separators = {
    --     none = { "", "" },
    --     left = { "", "  " },
    --     right = { "  ", "" },
    --     center = { "  ", "  " },
    --     tab = { "", "" },
    --     breadcrumbs = "  ",
    --     path = "  ",
    --   },
    --   -- Configure enabling/disabling of winbar
    --   winbar = {
    --     enabled = { -- whitelist buffer patterns
    --       filetype = { "gitsigns.blame" },
    --     },
    --     disabled = { -- blacklist buffer patterns
    --       buftype = { "nofile", "terminal" },
    --     },
    --   },
    -- },
  },
}
