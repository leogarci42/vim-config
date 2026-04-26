"STATUS LINE ------------------------------------------------------------ {{{

set noexpandtab
set tabstop=4
set shiftwidth=4
set softtabstop=0

" }}}

call plug#begin()

" ---- File Tree ----
Plug 'preservim/nerdtree'

" ---- LLVM IR / TableGen syntax highlighting ----
Plug 'rhysd/vim-llvm'

" ---- LSP client (pure Vimscript, no Node required) ----
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'

" ---- ALE: linting + clang-tidy + clang-format ----
Plug 'dense-analysis/ale'

" ---- Auto-close brackets ----
Plug 'jiangmiao/auto-pairs'

call plug#end()

" ===========================================================================
" VIM-LSP + CLANGD CONFIGURATION
" ===========================================================================
" Prerequisites (run once):
"   sudo apt install clangd        (Linux)
"   brew install llvm              (macOS, clangd will be in $(brew --prefix llvm)/bin)
"   For per-project accuracy: cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON .

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

" Show diagnostics inline
let g:lsp_diagnostics_enabled = 1
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_diagnostics_virtual_text_enabled = 0
let g:lsp_document_highlight_enabled = 1

" Signs in the gutter
let g:lsp_signs_enabled = 1
let g:lsp_signs_error   = {'text': '✗'}
let g:lsp_signs_warning = {'text': '⚠'}
let g:lsp_signs_hint    = {'text': '➜'}

" Completion
let g:asyncomplete_auto_popup = 1
let g:asyncomplete_auto_completeopt = 1
set completeopt=menuone,noinsert,noselect

" LSP key mappings (only active in LSP-supported buffers)
function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    nmap <buffer> gd          <plug>(lsp-definition)
    nmap <buffer> gy          <plug>(lsp-type-definition)
    nmap <buffer> gr          <plug>(lsp-references)
    nmap <buffer> <leader>rn  <plug>(lsp-rename)
    nmap <buffer> K           <plug>(lsp-hover)
    nmap <buffer> <leader>ac  <plug>(lsp-code-action)
    nmap <buffer> <leader>f   <plug>(lsp-document-format)
    nmap <buffer> <leader>h   <plug>(lsp-switch-source-header)
    nmap <buffer> [g          <plug>(lsp-previous-diagnostic)
    nmap <buffer> ]g          <plug>(lsp-next-diagnostic)
endfunction

augroup lsp_install
    autocmd!
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

" Tab to scroll through completion popup
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <CR>    pumvisible() ? asyncomplete#close_popup() : "\<CR>"

" ===========================================================================
" ALE CONFIGURATION (linting + formatting)
" ===========================================================================
let g:ale_linters = {
    \ 'c':   ['clangd', 'clang-tidy'],
    \ 'cpp': ['clangd', 'clang-tidy'],
    \ }
let g:ale_fixers = {
    \ '*':   ['remove_trailing_lines', 'trim_whitespace'],
    \ 'c':   ['clang-format'],
    \ 'cpp': ['clang-format'],
    \ }

let g:ale_c_clangformat_options = '--style=LLVM'
let g:ale_lint_on_text_changed  = 'never'
let g:ale_lint_on_insert_leave  = 1
let g:ale_lint_on_save          = 1
let g:ale_fix_on_save           = 0   " set to 1 to auto-format on every save
let g:ale_sign_error            = '✗'
let g:ale_sign_warning          = '⚠'

" ===========================================================================
" END LSP / ALE CONFIG
" ===========================================================================

set nocompatible
filetype on
filetype plugin on
filetype indent on
syntax on

set number
set cursorline
set cursorcolumn
set shiftwidth=4
set tabstop=4
set nobackup
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
set foldenable
set foldmethod=marker
set updatetime=300
set signcolumn=yes

" norminette / syntastic (42 school)
let g:syntastic_c_checkers                = ['norminette', 'gcc']
let g:syntastic_aggregate_errors          = 1
let g:syntastic_c_norminette_exec         = 'norminette'
let g:c_syntax_for_h                      = 1
let g:syntastic_c_include_dirs            = ['include', '../include', '../../include', 'libft', '../libft/include', '../../libft/include']
let g:syntastic_c_norminette_args         = '-R CheckTopCommentHeader'
let g:syntastic_check_on_open             = 1
let g:syntastic_always_populate_loc_list  = 1
let g:syntastic_auto_loc_list             = 1
let g:syntastic_check_on_wq               = 0

hi Normal guibg=NONE ctermbg=NONE
colorscheme molokai

" LLVM file types
autocmd BufRead,BufNewFile *.ll set filetype=llvm
autocmd BufRead,BufNewFile *.bc set filetype=llvm
autocmd BufRead,BufNewFile *.td set filetype=tablegen


" MAPPINGS --------------------------------------------------------------- {{{

inoremap jj <esc>
nnoremap o o<esc>
nnoremap n nzz

nnoremap <f5> :w <CR>:!clear <CR>:!python3 % <CR>

nmap <F2> :NERDTreeToggle<CR>

nnoremap <C-w>s :split<CR>
nnoremap <C-w>v :vsplit<CR>
nnoremap <C-w>h <C-w>h
nnoremap <C-w>j <C-w>j
nnoremap <C-w>k <C-w>k
nnoremap <C-w>l <C-w>l
nnoremap <C-w>c :close<CR>
nnoremap <C-w>o :only<CR>

" }}}


" VIMSCRIPT -------------------------------------------------------------- {{{

augroup filetype_vim
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
augroup END

if version >= 703
    set undodir=~/.vim/backup
    set undofile
    set undoreload=10000
endif

augroup cursor_off
    autocmd!
    autocmd WinLeave * set nocursorline nocursorcolumn
    autocmd WinEnter * set cursorline cursorcolumn
augroup END

if has('gui_running')
    colorscheme molokai
endif

" }}}


" STATUS LINE ------------------------------------------------------------ {{{

set statusline=%f\ %h%m%r
set statusline+=\ %=%y\ %l/%L\ (%p%%)

" }}}

hi Normal guibg=NONE ctermbg=NONE