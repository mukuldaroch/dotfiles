" =========================
" Plugin Manager (vim-plug)
" =========================

call plug#begin('~/.config/vim/plugged')

" -------------------------
" File tree
" -------------------------
Plug 'preservim/nerdtree'

" -------------------------
" Git integration
" -------------------------
Plug 'tpope/vim-fugitive'

" -------------------------
" Dashboard (alpha alternative)
" -------------------------
Plug 'mhinz/vim-startify'

" -------------------------
" Fuzzy finder (telescope alternative)
" Requires fzf installed on system
" -------------------------
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" -------------------------
" Commenting (comment.lua alternative)
" -------------------------
Plug 'tpope/vim-commentary'

" -------------------------
" Indentation detection
" -------------------------
Plug 'tpope/vim-sleuth'

" -------------------------
" Statusline / tabline
" -------------------------
Plug 'itchyny/lightline.vim'

" -------------------------
" Tmux navigation
" -------------------------
Plug 'christoomey/vim-tmux-navigator'

call plug#end()
