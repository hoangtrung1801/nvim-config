" Floaterm
let g:floaterm_gitcommit='floaterm'
let g:floaterm_autoinsert=1
"let g:floaterm_width=0.8
"let g:floaterm_height=0.8
let g:floaterm_wintitle=0
let g:floaterm_autoclose=1

nnoremap   <silent>   <F9>    :FloatermNew<CR>
tnoremap   <silent>   <F9>    <C-\><C-n>:FloatermNew<CR>
nnoremap   <silent>   <F10>    :FloatermPrev<CR>
tnoremap   <silent>   <F10>    <C-\><C-n>:FloatermPrev<CR>
nnoremap   <silent>   <F11>    :FloatermNext<CR>
tnoremap   <silent>   <F11>    <C-\><C-n>:FloatermNext<CR>
nnoremap   <silent>   <F12>   :FloatermToggle<CR>
tnoremap   <silent>   <F12>   <C-\><C-n>:FloatermToggle<CR>
