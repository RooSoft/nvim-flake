-- SECTION: basic
vim.o.encoding = "utf-8"
vim.o.mouse = "a"
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.expandtab = true
vim.o.showcmd = true -- new
vim.o.cmdheight = 1
vim.o.updatetime = 300
vim.o.shortmess = vim.o.shortmess .. "c"
vim.o.tm = 1000
vim.o.hidden = true
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.signcolumn = "yes:2"
vim.o.ai = true
vim.o.swapfile = false
vim.o.backup = false
vim.o.writebackup = false
vim.o.visualbell = false
vim.o.errorbells = false
vim.o.number = true
vim.o.relativenumber = true
vim.o.wrap = false
vim.o.hlsearch = false
vim.o.incsearch = true
vim.o.termguicolors = true
vim.o.guifont = "OverpassMono Nerd Font:h10"
vim.o.spell = true
vim.o.spelllang = "en_us"
vim.o.scrolloff = 10      -- new
vim.o.colorcolumn = "120" -- new

-- transparent background
-- vim.cmd.highlight("Normal guibg=none")V
-- vim.cmd.highlight("NonText guibg=none")
-- vim.api.nvim_set_hl(0, "ColorColumn", { ctermbg=0, bg=none })
-- vim.api.nvim_set_hl(0, "Normal", { ctermfg=White,  ctermbg=none })

--vim herasy
vim.cmd.aunmenu({ "PopUp.How-to\\ disable\\ mouse" })
vim.cmd.aunmenu({ "PopUp.-1-" })

-- Searching
vim.opt.incsearch = true  -- show when typing
vim.opt.hlsearch = true   -- highlight
vim.opt.smartcase = false -- do not override the ignorecase option
vim.opt.ignorecase = true -- ignorecase option :P

-- Clipboard
vim.o.clipboard = ""

-- map leader to <Space>
vim.keymap.set("n", " ", "<Nop>", { silent = true, remap = false })
vim.g.mapleader = " "

-- stop hiding double quotes in json files
vim.g.indentLine_setConceal = 0

-- SECTION: theme
vim.g.moonflyCursorColor = true
vim.g.moonflyNormalFloat = true
vim.g.moonflyTerminalColors = true
vim.g.moonflyTransparent = true
vim.g.moonflyUndercurls = true
vim.g.moonflyUnderlineMatchParen = true
vim.g.moonflyVirtualTextColor = true
-- vim.cmd.colorscheme("kanagawa")
vim.cmd([[colorscheme tokyonight]])

-- SECTION: cinnamon
require("cinnamon").setup()
-- SECTION: indent blankline
require("ibl").setup({
  indent = { char = "⋮" },
})

vim.g.cursorline_timeout = 0

-- SECTION: colorizer
require("colorizer").setup()
vim.keymap.set("n", "<leader>ct", "<cmd> ColorizerToggle<CR>")

-- SECTION: whichkey
local wk = require("which-key")
wk.setup({
	plugins = {
		marks = true,
		registers = true,
		spelling = {
			enabled = true,
			suggestions = 20,
		},
	},
	ignore_missings = false,
	triggers_blacklist = { i = { "j", "k" }, v = { "j", "k" } },
})
wk.register({
  ["<leader>"] = {
    f = {
      name = "+telescope",
      -- f = { "<cmd>Telescope find_files<cr>", "Find File" },
      -- r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File" },
      -- n = { "<cmd>enew<cr>", "New File" },
    },
    g = {
      name = "+global"
    },
    b = {
      name = "+bufferline"
    },
    c = {
      name = "+colorizer"
    },
    l = {
      name = "language server"
    },
    t = {
      name = "NvimTree"
    }
  },
})

require("Comment").setup()

require("toggleterm").setup({
  open_mapping = [[<Leader>e]],
  direction = "float",
  autochdir = true,
  insert_mappings = false,
  terminal_mappings = true,
  close_on_exit = true,
  size = function(term)
    if term.direction == "horizontal" then
      return 15
    elseif term.direction == "vertical" then
      return vim.o.columns * 0.4
    end
  end,
})

