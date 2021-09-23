syntax enable
syntax on

filetype plugin indent on

set encoding=UTF-8
set number relativenumber

set tabstop=2
set shiftwidth=2

set expandtab
set smarttab
set ai
set si
set wrap
set autoindent
set smartindent

"set lbr
"set tw=500

set hlsearch

set showmatch
set clipboard=unnamedplus
set ttimeoutlen=500
set wildmenu
set backspace=indent,eol,start
set history=500
set autoread
set mouse=a
set nobackup
set nowritebackup

set laststatus=2

set background=light
colorscheme PaperColor

set t_Co=256

set clipboard=unnamed

" Indent Guide
let g:indentLine_char = '│'
let g:indentLine_color_gui = '#363442'

" Font
set guifont=SpaceMono\ NF:h10

" detect .md as markdown instead of modula-2
autocmd BufNewFile,BufReadPost *.md set filetype=markdown
