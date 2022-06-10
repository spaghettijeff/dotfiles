" Window Navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Window Resize
nnoremap <M-h> :resize -2<CR>
nnoremap <M-j> :vertical resize -2<CR>
nnoremap <M-k> :vertical resize +2<CR>
nnoremap <M-l> :resize +2<CR>

" TAB & SHIFT-TAB to change buffer
nnoremap <TAB>   :bnext<CR>
nnoremap <S-TAB> :bprevious<CR>

" Latex mappings
autocmd FileType tex map <leader>c :w! \| !pdflatex % >/dev/null 2>&1 <CR> 
autocmd FileType tex map <leader>t YpkI\begin{<ESC>A}<ESC>jI\end{<ESC>A}<esc>kA

" LSP mappings
nnoremap  <silent> gd <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap  <silent> gD <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap  <silent> gr <cmd>lua vim.lsp.buf.refrences()<CR>
nnoremap  <silent> gi <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap  <silent> K <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap  <silent> <C-n> <cmd>lua vim.lsp.diagnostic.goto_prev()<CR>
nnoremap  <silent> <C-p> <cmd>lua vim.lsp.diagnostic.goto_next()<CR>
