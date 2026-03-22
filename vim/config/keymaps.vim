" ============================================================
" TAB MANAGEMENT
" ============================================================

" CTRL + j → go to next tab
nnoremap <C-j> :tabnext<CR>

" CTRL + k → go to previous tab
nnoremap <C-k> :tabprevious<CR>

" CTRL + t → open new tab with same file (if file exists)
nnoremap <C-t> :execute expand('%') == '' ? 'tabnew' : 'tabnew ' . expand('%')<CR>

" CTRL + w → close current tab (NOT window)
nnoremap <C-w> :tabclose<CR>

" ============================================================
" JUMP BACK / FORWARD
" ============================================================

" CTRL + , → jump back
nnoremap <C-,> <C-o>

" CTRL + . → jump forward
nnoremap <C-.> <C-i>

" ============================================================
" INSERT MODE ESCAPE
" ============================================================

" CTRL + ; → exit insert mode
inoremap <C-;> <Esc>

" ============================================================
" LEADER KEY
" ============================================================

let mapleader = " "
let maplocalleader = " "

" ============================================================
" SPLITS
" ============================================================

" Leader + v → vertical split
nnoremap <leader>v :vsplit<CR>

" Leader + hs → horizontal split
nnoremap <leader>hs :split<CR>

" ============================================================
" DISABLE NETRW (BUILT-IN FILE EXPLORER)
" ============================================================

let g:loaded_netrw = 1
let g:loaded_netrwPlugin = 1

" ============================================================
" UI / EDITOR OPTIONS
" ============================================================

" Enable line numbers
set number
set relativenumber

" Enable mouse support
set mouse=a

" Don't show mode (INSERT/NORMAL) in command line
set noshowmode

" Use system clipboard
set clipboard=unnamedplus

" Better indentation for wrapped lines
set breakindent

" Persistent undo history
set undofile

" Case-insensitive search unless capital letters used
set ignorecase
set smartcase

" Always show sign column
set signcolumn=yes

" Faster update time
set updatetime=250

" Faster which-key / mapped key timeout
set timeoutlen=300

" Open splits to the right & bottom
set splitright
set splitbelow

" Show whitespace characters
set list
set listchars=tab:»\ ,trail:·,nbsp:␣

" Live preview for substitute commands
" set inccommand=split

" Highlight current line
set cursorline

" Keep 10 lines visible above/below cursor
set scrolloff=10

" Highlight search results
set hlsearch

" Hide command line unless needed
" set cmdheight=0

" ============================================================
" HIGHLIGHT ON YANK
" ============================================================

augroup highlight_yank
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
augroup END

" ============================================================
" INSERT MODE MOVEMENT
" ============================================================

" Move to start of line
inoremap <C-i> <Esc>^i

" Move to end of line
inoremap <C-a> <End>

" Cursor left/right
inoremap <C-h> <Left>
inoremap <C-l> <Right>

" ============================================================
" NORMAL MODE KEYMAPS
" ============================================================

" Clear search highlights
nnoremap <Esc> :noh<CR>

" Window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" Save file
nnoremap <C-s> :w<CR>

" ============================================================
" QUIT / SAVE SHORTCUTS
" ============================================================

" Quit
nnoremap <leader>q :q<CR>

" Force quit
nnoremap <leader>qq :q!<CR>

" Save
nnoremap <leader>w :w<CR>

" ============================================================
" LSP
" ============================================================

" Restart LSP
nnoremap <leader>lr :LspRestart<CR>

" ============================================================
" MARKDOWN CONCEAL (HIDE ``` BACKTICKS)
" ============================================================

augroup markdown_conceal
    autocmd!
    autocmd FileType markdown highlight Conceal ctermfg=gray guifg=gray
    autocmd FileType markdown syntax match markdownCodeDelimiter /```/ conceal
    autocmd FileType markdown set conceallevel=2
augroup END


" =========================
" FZF KEYMAPS (Vim)
" =========================

" Help tags
nnoremap <leader>sh :Helptags<CR>

" Keymaps
nnoremap <leader>sk :Maps<CR>

" Find files
nnoremap <leader>sf :Files<CR>
nnoremap <leader>s  :Files<CR>

" Search word under cursor
nnoremap <leader>sw :Rg <C-r><C-w><CR>

" Live grep
nnoremap <leader>sg :Rg<CR>

" Diagnostics (Vim has no LSP UI here, closest equivalent)
nnoremap <leader>sd :copen<CR>

" Resume last fzf
nnoremap <leader>sr :History:<CR>

" Recent files
nnoremap <leader>s. :History<CR>

" Buffers
nnoremap <leader><leader> :Buffers<CR>

" Fuzzy search in current buffer
nnoremap <leader>/ :BLines<CR>

" Grep only in open files (closest Vim equivalent)
nnoremap <leader>s/ :Rg --open-files<CR>

" Search Vim config files
nnoremap <leader>sn :Files ~/.vim<CR>


" =========================
" NERDTREE CUSTOM KEYMAPS
" =========================
"
" Global leader mapping to toggle NERDTree
nnoremap <leader>e :NERDTreeToggle<CR>

" NERDTree buffer-local mappings
augroup nerdtree_keymaps
    autocmd!
    autocmd FileType nerdtree call s:nerdtree_keymaps()
augroup END

function! s:nerdtree_keymaps() abort
    " Navigation
    nnoremap <buffer> l <CR>
    nnoremap <buffer> h -
    nnoremap <buffer> q :NERDTreeClose<CR>

    " Splits / Tabs
    nnoremap <buffer> <C-v> i
    nnoremap <buffer> <C-x> s
    nnoremap <buffer> <C-t> t

    " File operations
    nnoremap <buffer> a m
    nnoremap <buffer> r R
    nnoremap <buffer> d D
    nnoremap <buffer> c y
    nnoremap <buffer> x d
    nnoremap <buffer> p p

    " Refresh
    nnoremap <buffer> R :NERDTreeRefreshRoot<CR>

    " Filters
    nnoremap <buffer> H :NERDTreeToggleHidden<CR>
    nnoremap <buffer> I :NERDTreeToggleIgnore<CR>
endfunction
