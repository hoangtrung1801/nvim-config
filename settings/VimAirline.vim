"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Vim Airline 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:airline_powerline_fonts = 1 									" Enable 
" enable tabline
let g:airline_theme='onedark' 										" Theme OneDark
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
