set nocompatible
syntax on
filetype on
filetype indent on
filetype plugin on
filetype plugin indent on
set clipboard=unnamedplus " https://stackoverflow.com/a/8757876
set autochdir
set history=4096
set nobackup
set noswapfile
set autoread
set autowrite
set whichwrap+=<,>,[,] " https://stackoverflow.com/a/2574203
set backspace=indent,eol,start " same as above
" UI
set mouse=a
set termguicolors
set cursorline
set cursorcolumn
set nowrap
set novisualbell
set noerrorbells
set list
set showbreak=↪\
set listchars=tab:→\ ,extends:›,precedes:‹,nbsp:␣,trail:·
set showcmd
set number
" Ident
set autoindent
set smartindent
set smarttab
set shiftround
set expandtab
set shiftwidth=4
set tabstop=4

" Search
set hlsearch
set incsearch
set ignorecase
set smartcase
set gdefault
set magic

" Keymap

let mapleader=" "
imap <C-P> <Up>
imap <C-F> <Right>
imap <C-N> <Down>
imap <C-B> <Left>
imap <C-A> <Home>
imap <C-E> <End>
imap <C-D> <Del>
nmap <Tab> <Leader><Leader>
vmap <Tab> <Leader><Leader>


" Plugins
let g:airline_powerline_fonts = 1
nmap <leader>/ <Plug>CommentaryLine
xmap <leader>/ <Plug>Commentary
omap <leader>/ <Plug>Commentary

" Colorscheme
set background=dark
colorscheme gruvbox
