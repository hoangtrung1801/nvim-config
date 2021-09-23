let g:python3_host_prog = 'C:\Users\Nha\AppData\Local\Programs\Python\Python38\python.EXE'
let g:python_host_prog = 'C:\Users\Nha\AppData\Local\Programs\Python\Python38\python.EXE'

" Config ale
"let g:ale_disable_lsp = 1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" -> Vim Plug
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call plug#begin('C:/Users/Nha/AppData/Local/nvim/plugged')

" Vim airline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

"Emmet vim
"Plug 'mattn/emmet-vim'

" Better Syntax Support
Plug 'sheerun/vim-polyglot'
"Plug 'w0rp/ale'

" File Explorer
"Plug 'scrooloose/NERDTree'

" Auto pairs for '(' '[' '{'
Plug 'jiangmiao/auto-pairs'

"Coc extension"
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Ctrl P
Plug 'kien/ctrlp.vim'

" Nerdcommenter
Plug 'preservim/nerdcommenter'

" Icon
Plug 'ryanoasis/vim-devicons'

" Expand word
Plug 'terryma/vim-expand-region'

" Move line
Plug 'matze/vim-move'

" Surround vim
Plug 'tpope/vim-surround'

" Multi cursor
Plug 'mg979/vim-visual-multi', {'branch': 'master'}

" Close tag
Plug 'alvan/vim-closetag'

" Syntax for js
Plug 'yuezk/vim-js'

" Pretty for react
Plug 'pangloss/vim-javascript'
Plug 'MaxMEllon/vim-jsx-pretty'

" choosewin, choose window easily
"Plug 't9md/vim-choosewin'

" Float term
Plug 'voldikss/vim-floaterm'

" hightlight indent
Plug 'yggdroot/indentline'

call plug#end()
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

for f in split(glob('~/AppData/Local/nvim/settings/*.vim'), '\n')
  exe 'source' f
endfor

" Return to last edit position when opening files (You want this!)
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" Clear all buffer but only one
command! BufOnly silent! execute "%bd|e#|bd#"

" Auto reload content changed outside
au CursorHold,CursorHoldI * checktime
au FocusGained,BufEnter * :checktime
autocmd FocusGained,BufEnter,CursorHold,CursorHoldI *
      \ if mode() !~ '\v(c|r.?|!|t)' && getcmdwintype() == '' | checktime | endif
autocmd FileChangedShellPost *
      \ echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None

" Disable automatic comment in newline
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Return to last edit position when opening files (You want this!)
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

"auto header cpp"
autocmd BufNewFile *.cpp r D:\BaitapC++\CodeMau.cpp


" Ale config 
"let g:ale_fixers = {
 "\ 'javascript': ['eslint']
 "\ }
 
"let g:ale_sign_error = '❌'
"let g:ale_sign_warning = '⚠️'

"let g:ale_fix_on_save = 1


