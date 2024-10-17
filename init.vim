call plug#begin('~/.config/nvim/plugged')

" Vim RSpec
Plug 'thoughtbot/vim-rspec'

" Google and Go-specific plugins
Plug 'google/vim-codefmt'
Plug 'google/vim-maktaba'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

" NERDTree and Devicons
Plug 'preservim/nerdtree'
Plug 'ryanoasis/vim-devicons'
Plug 'Xuyuanp/nerdtree-git-plugin'

" Ruby plugins
Plug 'tpope/vim-rails'
Plug 'vim-ruby/vim-ruby'

" Linting with ALE
Plug 'dense-analysis/ale'

" Fuzzy Finder (Telescope)
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.8' }

" Treesitter for syntax highlighting
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Git Integration
Plug 'tpope/vim-fugitive'

" Autocompletion and Snippets
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'neovim/nvim-lspconfig'

" Utility Plugins
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'andymass/vim-matchup'
Plug 'tpope/vim-sleuth'
Plug 'mhinz/vim-signify'

Plug 'hashivim/vim-terraform'
Plug 'b0o/SchemaStore.nvim'
Plug 'ekalinin/Dockerfile.vim'

call plug#end()

set number
syntax enable

nnoremap <leader>ff :Telescope find_files<CR>
nnoremap <leader>be :Telescope buffers<CR>

" Terraform settings
let g:terraform_fmt_on_save=1
let g:terraform_align=1

" NERDTree settings: Auto-open NERDTree on startup
autocmd VimEnter * NERDTree
let NERDTreeShowHidden=1
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree")
    \ && b:NERDTree.isTabTree()) | q | endif
autocmd VimEnter * wincmd p
" autocmd BufEnter * if !&buftype && exists("t:NERDTreeBufName") && bufname("#") !~ 'NERD_tree_' | execute 'NERDTreeFind' | wincmd p | endif

" Ruby-specific settings
let g:ruby_indent_block_style = 'do'

" ALE configuration for linting Ruby, Go, and JavaScript/TypeScript
let g:ale_ruby_rubocop_executable = 'bundle'
let g:ale_fixers = {
      \ 'ruby': ['rubocop'],
      \ 'go': ['gofmt', 'goimports'],
      \ 'typescript': ['prettier'],
      \ 'javascript': ['prettier'],
      \ }
let g:ale_ruby_rubocop_options = '--safe-auto-correct'
let g:ale_go_golangci_lint_options = '--enable-all'
let g:ale_lint_on_enter = 1
let g:ale_lint_on_save = 1

" Go-specific settings
let g:go_fmt_command = "goimports"
let g:go_auto_type_info = 1
let g:go_def_mapping_enabled = 0
autocmd BufWritePre *.go :silent! lua vim.lsp.buf.format({ timeout_ms = 2000 })

nmap <leader>f :ALEFix<CR>

nnoremap <C-_> :Commentary<CR>
vnoremap <C-_> :Commentary<CR>

" RSpec Commands
nnoremap <leader>rf :call RunCurrentSpecFile()<CR>
nnoremap <leader>rl :call RunLastSpec()<CR>
nnoremap <leader>rb :call RunNearestSpec()<CR>
nnoremap <leader>ra :call RunAllSpecs()<CR>

" Enable Tree-sitter-based folding
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
set foldlevelstart=99

lua <<EOF
require'nvim-treesitter.configs'.setup {
    ensure_installed = { "go", "ruby", "lua", "python", "typescript", "javascript" },
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false
    },
    indent = {
        enable = true
    },
}

local cmp = require'cmp'

cmp.setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    mapping = {
        ['<C-k>'] = cmp.mapping.select_prev_item(),
        ['<C-j>'] = cmp.mapping.select_next_item(),
        ['<C-n>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.close(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
    },
    sources = {
        { name = 'nvim_lsp' },
        { name = 'buffer' },
        { name = 'path' },
        { name = 'luasnip' },
    }
})

require('lspconfig').ts_ls.setup{
  on_attach = function(client, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    local opts = { noremap=true, silent=true }
    buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)

    if client.server_capabilities.document_formatting then
      vim.api.nvim_command [[augroup Format]]
      vim.api.nvim_command [[autocmd! * <buffer>]]
      vim.api.nvim_command [[autocmd BufWritePre <buffer> lua vim.lsp.buf.format()]]
      vim.api.nvim_command [[augroup END]]
    end
  end,
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
}

require('lspconfig').yamlls.setup {
  settings = {
    yaml = {
      schemas = require('schemastore').yaml.schemas(),
    },
  },
}

require'lspconfig'.gopls.setup{}
require'lspconfig'.solargraph.setup{}
EOF
