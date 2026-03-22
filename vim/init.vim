" Leader MUST be first
let mapleader = " "
let maplocalleader = " "

source ~/.config/vim/config/keymaps.vim

" Set the width of the NERDTree window
let g:NERDTreeWinSize = 30

" Automatically open NERDTree when vim starts on a directory
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | execute 'NERDTree' argv()[0] | endif

" Keep NERDTree open when switching buffers
let g:NERDTreeQuitOnOpen = 0

set clipboard=unnamedplus
