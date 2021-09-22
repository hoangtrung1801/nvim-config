let mapleader=","

"Map Tab to ESC"
inoremap jj <ESC>

" Map "
map <C-a> gg0vG$ 
map <C-c> "+y

" Toggle NerdTree
map <F2> :NERDTreeToggle <CR>
map <F3> :NERDTreeFind <CR>

" Move faster
nmap <C-h> 7h 
nmap <C-j> 7j 
nmap <C-k> 7k
nmap <C-l> 7l
vmap <C-h> 7h
vmap <C-j> 7j
vmap <C-k> 7k
vmap <C-l> 7l

nmap H ^
nmap L $
vmap H ^
vmap L $


" Disable highlight when <leader><cr> is pressed
map <silent> <leader><cr> :noh<cr>

" Useful mappings for managing tabs
map <leader>tn :tabnew<cr>
map <leader>to :tabonly<cr>
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove 
map <leader>t<leader> :tabnext<cr>
" Opens a new tab with the current buffer's path
" Super useful when editing files in the same directory
map <leader>te :tabedit <C-r>=expand("%:p:h")<cr>/

" Better tabbing
vnoremap < <gv
vnoremap > >gv

" Use alt + hjkl to resize windows
"nnoremap <M-j>    :resize -2<CR>
"nnoremap <M-k>    :resize +2<CR>
"nnoremap <M-h>    :vertical resize -2<CR>
"nnoremap <M-l>    :vertical resize +2<CR>

" Jump window
"nmap <Leader>ww <Plug>(choosewin)

" Close the current buffer
map <leader>bd :bd<cr>
" Close all the buffers
map <leader>ba :bufdo bd<cr>
map <leader>l :bnext<cr>
map <leader>h :bprevious<cr>

" Save
nmap <C-S> :w<cr>
imap <C-S> <esc>:w<cr>a
