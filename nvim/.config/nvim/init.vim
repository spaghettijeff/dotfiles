call plug#begin('~/.config/plugged')
Plug 'scrooloose/nerdtree'
Plug 'itchyny/lightline.vim'
Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }
Plug 'lifepillar/vim-mucomplete'
Plug 'kassio/neoterm'
Plug 'kovisoft/slimv'
call plug#end()


syntax enable
colorscheme gruvbox
set background=dark
set encoding=utf-8
set nowrap
set tabstop=4
set shiftwidth=4
set softtabstop=4
set smarttab
set expandtab
set smartindent
set autoindent
set number
set showcmd
set wildmenu
set showmatch
set incsearch
set hlsearch
set laststatus=2
set noshowmode
set spelllang=en
set pyxversion=3
set nocompatible

filetype plugin on

let g:mapleader="\<Space>"
set omnifunc=syntaxcomplete#Complete
set noinfercase
set completeopt-=preview
set completeopt+=menuone,noselect
set shortmess+=c
let g:mucomplete#enable_auto_at_startup = 1


source $HOME/.config/nvim/key_binds.vim
map <C-n> :NERDTreeToggle<CR>

source $HOME/.config/nvim/paredit.vim
let g:slimv_swank_cmd='T sbcl --load ~/.config/plugged/slimv/slime/start-swank.lisp &'
let g:slimv_impl='sbcl'
let g:slimv_repl_split=2
let g:slimv_repl_split_size=18
let g:slimv_keybindings=2

