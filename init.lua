vim.g.mapleader = ","

vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.python3_host_prog = "/Users/brvy/.local/bin/pynvim-python"

vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.smarttab = true
vim.opt.number = true

-- Keymaps
vim.keymap.set('n', '<Leader>r', ':luafile $MYVIMRC<CR>')
vim.keymap.set('n', '<Leader>e', ':NvimTreeToggle<CR>')
vim.keymap.set('n', '<Leader>w', ':w<CR>')
vim.keymap.set('i', 'jk', '<Esc>', { noremap = true, desc = 'Exit insert mode with jk' })

-- Theme related
vim.pack.add { { src = "https://github.com/catppuccin/nvim", name = "catppuccin" } }

require("catppuccin").setup({
    flavour = "latte",
})

vim.cmd.colorscheme "catppuccin-nvim"

--- Plenary
vim.pack.add { { src = "https://github.com/nvim-lua/plenary.nvim", name = "plenary.nvim" } }

--- Telescope
vim.pack.add { { src = "https://github.com/nvim-telescope/telescope.nvim", name = "telescope.nvim" } }
vim.pack.add { { src = "https://github.com/nvim-telescope/telescope-ui-select.nvim" } }

local telescope = require('telescope')
telescope.setup {
    extensions = {
        ["ui-select"] = {
            require("telescope.themes").get_dropdown {}
        }
    }
}
telescope.load_extension("ui-select")

--- Mason
vim.pack.add { { src = "https://github.com/mason-org/mason.nvim", name = "mason.nvim" } }
vim.pack.add { { src = "https://github.com/neovim/nvim-lspconfig", name = "nvim-lspconfig" } }
vim.pack.add { { src = "https://github.com/mason-org/mason-lspconfig.nvim" } }

require('mason').setup()
require('mason-lspconfig').setup()

--- CtrlP
vim.pack.add { { src = "https://github.com/ctrlpvim/ctrlp.vim" } }

--- CMP
vim.pack.add { { src = "https://github.com/hrsh7th/nvim-cmp" } }
vim.pack.add { { src = "https://github.com/hrsh7th/cmp-nvim-lsp" } }
vim.pack.add { { src = "https://github.com/rafamadriz/friendly-snippets"} }

--- WhichKey
vim.pack.add { { src = "https://github.com/nvim-tree/nvim-web-devicons" } }
vim.pack.add { { src = "https://github.com/folke/which-key.nvim" } }
local wk = require("which-key")
wk.add({
    { "<leader>?", function() wk.show() end },
})

--- Files
vim.pack.add { { src = "https://github.com/kyazdani42/nvim-tree.lua" } }

require("nvim-tree").setup()

--- Project
vim.pack.add { { src = "https://github.com/ahmedkhalf/project.nvim" } }

--- Status line
vim.pack.add { { src = "https://github.com/nvim-lualine/lualine.nvim" } }
require('lualine').setup()
