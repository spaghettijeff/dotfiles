let g:mapleader="\<Space>"

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

source $HOME/.config/nvim/key_binds.vim

call plug#begin('~/.config/plugged')
Plug 'scrooloose/nerdtree'
Plug 'itchyny/lightline.vim'
Plug 'vimwiki/vimwiki'
Plug 'neovim/nvim-lspconfig'
call plug#end()

map <C-n> :NERDTreeToggle<CR>

