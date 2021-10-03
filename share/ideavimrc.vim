" GitHub https://github.com/JetBrains/ideavim
let mapleader=" "
set surround
set easymotion
set commentary
set clipboard=unnamedplus " https://stackoverflow.com/a/8757876

set whichwrap+=<,>,[,] " https://stackoverflow.com/a/2574203
set backspace=indent,eol,start " same as above

imap <C-P> <Up>
imap <C-F> <Right>
imap <C-N> <Down>
imap <C-B> <Left>
imap <C-A> <Home>
imap <C-E> <End>
imap <C-D> <Del>
nmap <Tab> <Leader><Leader>
vmap <Tab> <Leader><Leader>
nmap s <Plug>(easymotion-bd-f2)
nmap <Leader>/ gcc
xmap <Leader>/ gc
omap <Leader>/ gc
