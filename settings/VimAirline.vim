"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Vim Airline 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:airline_powerline_fonts = 1 									" Enable 
" enable tabline
let g:airline_theme='base16_atelier_cave_light' 										" Theme OneDark
let g:airline#extensions#tabline#enabled = 1 						" Enable Tab bar
let g:airline#extensions#tabline#left_sep = ' ' 					" Enable Tab seperator 
let g:airline#extensions#tabline#left_alt_sep = '|' 				" Enable Tab seperator
let g:airline#extensions#tabline#formatter = 'default'
let g:airline#extensions#tabline#fnamemod = ':t' 					" Set Tab name as file name

let g:airline#extensions#whitespace#enabled = 0  					" Remove warning whitespace"

let g:airline_section_c_only_filename = 1

function! AirlineInit()
    let g:airline_section_a = airline#section#create(['mode', ' ', 'branch'])
    let g:airline_section_y = airline#section#create(['%B'])
    let g:airline_section_z = airline#section#create_right(['%l : %c'])
endfunction
autocmd VimEnter * call AirlineInit()

" Set this. Airline will handle the rest.
let g:airline#extensions#ale#enabled = 1

" disable unused extensions (performance)
let g:airline#extensions#bufferline#enabled = 0
let g:airline#extensions#capslock#enabled   = 0
let g:airline#extensions#csv#enabled        = 0
let g:airline#extensions#ctrlspace#enabled  = 0
let g:airline#extensions#eclim#enabled      = 0
let g:airline#extensions#hunks#enabled      = 0
let g:airline#extensions#nrrwrgn#enabled    = 0
let g:airline#extensions#promptline#enabled = 0
let g:airline#extensions#syntastic#enabled  = 0
let g:airline#extensions#taboo#enabled      = 0
let g:airline#extensions#tagbar#enabled     = 0
let g:airline#extensions#virtualenv#enabled = 0
let g:airline#extensions#whitespace#enabled = 0
