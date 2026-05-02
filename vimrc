set nocompatible

" ============================================================================
" BASICS
" ============================================================================
set noexpandtab
set tabstop=4
set shiftwidth=4
set softtabstop=0

set number
set cursorline
set cursorcolumn
set scrolloff=10
set nowrap
set incsearch
set ignorecase
set smartcase
set showcmd
set showmode
set showmatch
set hlsearch
set history=1000
set wildmenu
set wildmode=list:longest
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx
set updatetime=300
set signcolumn=yes

" Folding (FIXED: no more marker issues)
set foldenable
set foldmethod=indent

" Performance
set lazyredraw
set ttyfast

" No swap/backup
set nobackup

" ============================================================================
" PLUGINS
" ============================================================================
call plug#begin()

Plug 'preservim/nerdtree'
Plug 'rhysd/vim-llvm'

" LSP (clangd)
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'

" Lint / format
Plug 'dense-analysis/ale'

" QoL
Plug 'jiangmiao/auto-pairs'

call plug#end()

" ============================================================================
" COLORS + TRANSPARENCY (FIXED)
" ============================================================================
syntax on
colorscheme molokai

augroup TransparentBG
    autocmd!
    autocmd ColorScheme * highlight Normal guibg=NONE ctermbg=NONE
    autocmd ColorScheme * highlight NonText guibg=NONE ctermbg=NONE
    autocmd ColorScheme * highlight LineNr guibg=NONE ctermbg=NONE
    autocmd ColorScheme * highlight Folded guibg=NONE ctermbg=NONE
    autocmd ColorScheme * highlight EndOfBuffer guibg=NONE ctermbg=NONE
augroup END

" Apply immediately
highlight Normal guibg=NONE ctermbg=NONE
highlight NonText guibg=NONE ctermbg=NONE
highlight LineNr guibg=NONE ctermbg=NONE
highlight Folded guibg=NONE ctermbg=NONE
highlight EndOfBuffer guibg=NONE ctermbg=NONE

" ============================================================================
" FILETYPE
" ============================================================================
filetype on
filetype plugin on
filetype indent on

" LLVM types
autocmd BufRead,BufNewFile *.ll set filetype=llvm
autocmd BufRead,BufNewFile *.bc set filetype=llvm
autocmd BufRead,BufNewFile *.td set filetype=tablegen

" ============================================================================
" LSP + CLANGD
" ============================================================================
if executable('clangd-12') || executable('clangd')
    let s:clangd_bin = executable('clangd-12') ? 'clangd-12' : 'clangd'
    au User lsp_setup call lsp#register_server({
        \ 'name': 'clangd',
        \ 'cmd': {server_info -> [s:clangd_bin,
        \   '--background-index',
        \   '--clang-tidy',
        \   '--header-insertion=iwyu',
        \   '--completion-style=detailed',
        \   '--fallback-style=LLVM'
        \ ]},
        \ 'allowlist': ['c', 'cpp', 'objc', 'objcpp'],
        \ })
endif

let g:lsp_diagnostics_enabled = 1
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_diagnostics_virtual_text_enabled = 0
let g:lsp_document_highlight_enabled = 1

let g:lsp_signs_enabled = 1
let g:lsp_signs_error   = {'text': '✗'}
let g:lsp_signs_warning = {'text': '⚠'}
let g:lsp_signs_hint    = {'text': '➜'}

" Completion
let g:asyncomplete_auto_popup = 1
set completeopt=menuone,noinsert,noselect

function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    nmap <buffer> gd          <plug>(lsp-definition)
    nmap <buffer> gy          <plug>(lsp-type-definition)
    nmap <buffer> gr          <plug>(lsp-references)
    nmap <buffer> <leader>rn  <plug>(lsp-rename)
    nmap <buffer> K           <plug>(lsp-hover)
    nmap <buffer> <leader>ac  <plug>(lsp-code-action)
    nmap <buffer> <leader>f   <plug>(lsp-document-format)
    nmap <buffer> [g          <plug>(lsp-previous-diagnostic)
    nmap <buffer> ]g          <plug>(lsp-next-diagnostic)
endfunction

augroup lsp_install
    autocmd!
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

" Completion navigation
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <CR> pumvisible() ? asyncomplete#close_popup() : "\<CR>"

" ============================================================================
" ALE (FIXED: no clangd conflict)
" ============================================================================
let g:ale_linters = {
    \ 'c':   ['clang-tidy'],
    \ 'cpp': ['clang-tidy'],
    \ }

let g:ale_fixers = {
    \ '*':   ['remove_trailing_lines', 'trim_whitespace'],
    \ 'c':   ['clang-format'],
    \ 'cpp': ['clang-format'],
    \ }

let g:ale_c_clangformat_options = '--style=LLVM'
let g:ale_lint_on_insert_leave  = 1
let g:ale_lint_on_save          = 1
let g:ale_fix_on_save           = 0

let g:ale_sign_error   = '✗'
let g:ale_sign_warning = '⚠'

" ============================================================================
" KEYMAPS
" ============================================================================
inoremap jj <esc>
nnoremap o o<esc>
nnoremap n nzz

nnoremap <F5> :w<CR>:!clear<CR>:!python3 %<CR>
nnoremap <F2> :NERDTreeToggle<CR>

" splits
nnoremap <C-w>s :split<CR>
nnoremap <C-w>v :vsplit<CR>
nnoremap <C-w>c :close<CR>
nnoremap <C-w>o :only<CR>

" ============================================================================
" UNDO
" ============================================================================
if version >= 703
    set undodir=~/.vim/backup//
    set undofile
    set undoreload=10000
endif

" ============================================================================
" CURSOR UI
" ============================================================================
augroup cursor_off
    autocmd!
    autocmd WinLeave * set nocursorline nocursorcolumn
    autocmd WinEnter * set cursorline cursorcolumn
augroup END

" ============================================================================
" STATUSLINE
" ============================================================================
set statusline=%f\ %h%m%r
set statusline+=\ %=%y\ %l/%L\ (%p%%)
