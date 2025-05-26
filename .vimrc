" ~/.vimrc - Comprehensive Vim Configuration
" Cross-platform Vim configuration for development environments

" =============================================================================
" GENERAL SETTINGS
" =============================================================================

set nocompatible              " Disable Vi compatibility
set encoding=utf-8            " Set UTF-8 encoding
set fileencoding=utf-8        " File encoding
set fileformat=unix           " Unix line endings

" Enable syntax highlighting and file type detection
syntax enable
filetype plugin indent on

" Basic editor behavior
set number                    " Show line numbers
set relativenumber           " Relative line numbers
set cursorline               " Highlight current line
set showmatch                " Show matching brackets
set wildmenu                 " Enhanced command-line completion
set wildmode=longest:full,full
set conceallevel=0           " Don't hide characters

" Search settings
set incsearch                " Incremental search
set hlsearch                 " Highlight search results
set ignorecase               " Case insensitive search
set smartcase                " Smart case sensitivity

" Indentation and formatting
set autoindent               " Auto-indent new lines
set smartindent              " Smart indentation
set tabstop=4                " Tab width
set shiftwidth=4             " Indentation width
set expandtab                " Use spaces instead of tabs
set smarttab                 " Smart tab handling

" Display settings
set wrap                     " Wrap long lines
set linebreak                " Break at word boundaries
set scrolloff=8              " Keep 8 lines visible when scrolling
set sidescrolloff=8          " Keep 8 columns visible when scrolling
set colorcolumn=80,120       " Show column markers
set laststatus=2             " Always show status line

" File handling
set autoread                 " Auto-reload changed files
set backup                   " Enable backups
set backupdir=~/.vim/backup// " Backup directory
set directory=~/.vim/swap//   " Swap file directory
set undofile                 " Persistent undo
set undodir=~/.vim/undo//     " Undo directory

" Create directories if they don't exist
if !isdirectory(expand("~/.vim/backup"))
    call mkdir(expand("~/.vim/backup"), "p")
endif
if !isdirectory(expand("~/.vim/swap"))
    call mkdir(expand("~/.vim/swap"), "p")
endif
if !isdirectory(expand("~/.vim/undo"))
    call mkdir(expand("~/.vim/undo"), "p")
endif

" =============================================================================
" KEY MAPPINGS
" =============================================================================

" Set leader key
let mapleader = ","
let maplocalleader = "\\"

" Quick save and quit
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>x :x<CR>

" Clear search highlighting
nnoremap <silent> <leader>/ :nohlsearch<CR>

" Better navigation
nnoremap j gj
nnoremap k gk
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Tab management
nnoremap <leader>tn :tabnew<CR>
nnoremap <leader>tc :tabclose<CR>
nnoremap <leader>th :tabprev<CR>
nnoremap <leader>tl :tabnext<CR>

" Buffer management
nnoremap <leader>bn :bnext<CR>
nnoremap <leader>bp :bprev<CR>
nnoremap <leader>bd :bdelete<CR>

" Quick edit vimrc
nnoremap <leader>ev :edit $MYVIMRC<CR>
nnoremap <leader>sv :source $MYVIMRC<CR>

" =============================================================================
" APPEARANCE
" =============================================================================

" Color scheme
if has("termguicolors")
    set termguicolors
endif

" Set colorscheme (fallback to default if not available)
try
    colorscheme desert
catch /^Vim\%((\a\+)\)\=:E185/
    " Colorscheme not found, use default
endtry

" Status line
set statusline=%f                           " File name
set statusline+=\ %m                        " Modified flag
set statusline+=\ %r                        " Read-only flag
set statusline+=\ %h                        " Help flag
set statusline+=\ %w                        " Preview flag
set statusline+=%=                          " Right align
set statusline+=\ %{&filetype}              " File type
set statusline+=\ %{&fileencoding}          " File encoding
set statusline+=\ %l/%L                     " Line/Total lines
set statusline+=\ %c                        " Column
set statusline+=\ %P                        " Percentage

" =============================================================================
" FILE TYPE SPECIFIC SETTINGS
" =============================================================================

augroup FileTypeSettings
    autocmd!
    
    " Python
    autocmd FileType python setlocal tabstop=4 shiftwidth=4 expandtab
    autocmd FileType python setlocal textwidth=79
    
    " JavaScript/TypeScript
    autocmd FileType javascript,typescript setlocal tabstop=2 shiftwidth=2 expandtab
    autocmd FileType json setlocal tabstop=2 shiftwidth=2 expandtab
    
    " HTML/CSS
    autocmd FileType html,css,scss setlocal tabstop=2 shiftwidth=2 expandtab
    
    " YAML
    autocmd FileType yaml setlocal tabstop=2 shiftwidth=2 expandtab
    
    " Markdown
    autocmd FileType markdown setlocal wrap linebreak textwidth=80
    autocmd FileType markdown setlocal spell
    
    " Shell scripts
    autocmd FileType sh,bash,zsh setlocal tabstop=4 shiftwidth=4 expandtab
    
    " Git commit messages
    autocmd FileType gitcommit setlocal textwidth=72
    autocmd FileType gitcommit setlocal spell
augroup END

" =============================================================================
" USEFUL FUNCTIONS
" =============================================================================

" Toggle line numbers
function! ToggleLineNumbers()
    if &number
        set nonumber
        set norelativenumber
    else
        set number
        set relativenumber
    endif
endfunction
nnoremap <leader>ln :call ToggleLineNumbers()<CR>

" Strip trailing whitespace
function! StripTrailingWhitespace()
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
endfunction
nnoremap <leader>sw :call StripTrailingWhitespace()<CR>

" Toggle paste mode
function! TogglePaste()
    if &paste
        set nopaste
        echo "Paste mode disabled"
    else
        set paste
        echo "Paste mode enabled"
    endif
endfunction
nnoremap <leader>p :call TogglePaste()<CR>

" =============================================================================
" PLUGINS (if vim-plug is available)
" =============================================================================

" Check if vim-plug is installed
if empty(glob('~/.vim/autoload/plug.vim'))
    echo "vim-plug not found. Install it with:"
    echo "curl -fLo ~/.vim/autoload/plug.vim --create-dirs"
    echo "  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
else
    " Plugin section
    call plug#begin('~/.vim/plugged')
    
    " Essential plugins
    Plug 'tpope/vim-sensible'         " Sensible defaults
    Plug 'tpope/vim-fugitive'         " Git integration
    Plug 'tpope/vim-surround'         " Surround text objects
    Plug 'tpope/vim-commentary'       " Comment handling
    
    " File navigation
    Plug 'preservim/nerdtree'         " File tree
    Plug 'ctrlpvim/ctrlp.vim'         " Fuzzy finder
    
    " Appearance
    Plug 'vim-airline/vim-airline'    " Status line
    Plug 'vim-airline/vim-airline-themes'
    
    " Language support
    Plug 'sheerun/vim-polyglot'       " Language pack
    
    call plug#end()
    
    " Plugin-specific settings
    if exists(':NERDTree')
        nnoremap <leader>nt :NERDTreeToggle<CR>
        nnoremap <leader>nf :NERDTreeFind<CR>
    endif
    
    if exists(':CtrlP')
        nnoremap <leader>ff :CtrlP<CR>
        nnoremap <leader>fb :CtrlPBuffer<CR>
    endif
endif

" =============================================================================
" NEOVIM SPECIFIC
" =============================================================================

if has('nvim')
    " Neovim-specific settings
    set inccommand=split          " Live preview of substitutions
    
    " Terminal settings
    tnoremap <Esc> <C-\><C-n>     " Easy escape from terminal mode
    tnoremap <C-h> <C-\><C-n><C-w>h
    tnoremap <C-j> <C-\><C-n><C-w>j
    tnoremap <C-k> <C-\><C-n><C-w>k
    tnoremap <C-l> <C-\><C-n><C-w>l
endif

" =============================================================================
" PLATFORM SPECIFIC
" =============================================================================

" Windows-specific settings
if has('win32') || has('win64')
    set shell=cmd
    set shellcmdflag=/c
endif

" =============================================================================
" LOCAL VIMRC
" =============================================================================

" Source local vimrc if it exists
if filereadable(expand("~/.vimrc.local"))
    source ~/.vimrc.local
endif
