-- place this file under ~/.config/nvim
-- Ensure packer is installed
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

-- Plugin list
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  -- LSP and Tools
  use 'neovim/nvim-lspconfig'
  use 'williamboman/mason.nvim'
  use 'williamboman/mason-lspconfig.nvim'
  use 'nvimtools/none-ls.nvim'
  
  -- Completion
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'L3MON4D3/LuaSnip'
  use 'saadparwaiz1/cmp_luasnip'

  -- Telescope (fuzzy finder)
  use {'nvim-telescope/telescope.nvim', requires = { 'nvim-lua/plenary.nvim' }}

  -- Treesitter (syntax highlighting)
use {
  'nvim-treesitter/nvim-treesitter',
  run = function()
    require('nvim-treesitter.install').update({ with_sync = true })
  end,
}

  -- UI
  use 'nvim-lualine/lualine.nvim'
  use 'nvim-tree/nvim-tree.lua'

  if packer_bootstrap then
    require('packer').sync()
  end
end)

-- ================================
-- 🌟 General Settings
-- ================================
vim.o.number = true
vim.o.relativenumber = true
vim.o.termguicolors = true
vim.o.signcolumn = "yes"
vim.o.tabstop = 2
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.smartindent = true
vim.g.mapleader = " "

-- ================================
-- 🧠 Treesitter
-- ================================
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "c", "cpp", "cmake", "bash", "json" },
  highlight = { enable = true },
}

-- ================================
-- 🔍 Telescope
-- ================================
require('telescope').setup()

vim.keymap.set('n', '<C-p>', require('telescope.builtin').find_files, {})
vim.keymap.set('n', '<C-f>', require('telescope.builtin').live_grep, {})
vim.keymap.set('n', '<leader>b', require('telescope.builtin').buffers, {})

-- ================================
-- 🤖 Completion Setup
-- ================================
local cmp = require'cmp'
cmp.setup({
  snippet = {
    expand = function(args)
      require'luasnip'.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }
})

-- ================================
-- ⚙️ LSP Setup (clangd)
-- ================================
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "clangd" },
})

local lspconfig = require("lspconfig")
lspconfig.clangd.setup({
  cmd = { "clangd", "--background-index", "--clang-tidy", "--header-insertion=iwyu" },
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

-- ================================
-- 🧼 Formatting with null-ls
-- ================================
local null_ls = require("null-ls")
null_ls.setup({
  sources = {
    null_ls.builtins.formatting.clang_format,
  },
})

vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format() end, {})

-- ================================
-- 📦 Lualine (status bar)
-- ================================
require('lualine').setup({
  options = {
    theme = 'onedark',  -- ← try other themes like 'tokyonight', 'onedark', 'dracula', 'auto'
  }
})

-- ================================
-- 🧭 LSP Keybindings
-- ================================
vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, {})
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})

-- ================================
-- 📁 Optional: File Explorer
-- ================================
require("nvim-tree").setup()
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", {})

-- ================================
-- 📜 Auto Commands
-- ================================
vim.cmd [[
  augroup FormatAutogroup
    autocmd!
    autocmd BufWritePre *.cpp,*.h lua vim.lsp.buf.format()
  augroup END
]]

