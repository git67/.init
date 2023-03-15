runtime! debian.vim

autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType yml setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType py setlocal ts=4 sts=2 sw=2 expandtab autoident shiftwidth=4 cursorline showmatch number 

let python_highlight_all = 1

if has("syntax")
  syntax on
endif

set showcmd 
set showmatch
set ignorecase
set smartcase 
set incsearch
set autowrite
set hidden  

if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif
