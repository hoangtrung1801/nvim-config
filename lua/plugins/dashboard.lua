---@type LazySpec
return {
  "goolord/alpha-nvim",
  opts = function(_, opts) -- override the options using lazy.nvim
    opts.section.header.val = { -- change the header section value
      "",
      "                    | |                            ",
      " __      _____  _ __| | _____ _ __   __ _  ___ ___ ",
      " \\ \\ /\\ / / _ \\| '__| |/ / __| '_ \\ / _` |/ __/ _ \\",
      "  \\ V  V / (_) | |  |   <\\__ \\ |_) | (_| | (_|  __/",
      "   \\_/\\_/ \\___/|_|  |_\\_\\___| .__/ \\__,_|\\___\\___|",
      "                             | |                   ",
      "                             |_|                   ",
      "",
    }

    -- opts.section.buttons.val = {
    --   opts.button("h", "  Say Hi", ':echo "Hello World!"<CR>'),
    -- }
  end,
}
