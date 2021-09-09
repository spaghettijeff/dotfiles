" Window Navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Window Resize
nnoremap <M-h> :resize -2<CR>
nnoremap <M-j> :resize +2<CR>
nnoremap <M-k> :vertical resize -2<CR>
nnoremap <M-l> :vertical resize +2<CR>

" TAB & SHIFT-TAB to change buffer
nnoremap <TAB>   :bnext<CR>
nnoremap <S-TAB> :bprevious<CR>

" Latex mappings
autocmd FileType tex map <leader>c :w! \| !pdflatex % >/dev/null 2>&1 <CR> 
autocmd FileType tex map <leader>t YpkI\begin{<ESC>A}<ESC>jI\end{<ESC>A}<esc>kA
