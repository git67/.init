runtime! debian.vim

autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType yml setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType py setlocal ts=4 sts=2 sw=2 expandtab autoident shiftwidth=4 cursorline showmatch number 

let python_highlight_all = 1
syntax enable

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
set mouse=a
