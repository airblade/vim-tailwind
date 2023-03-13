vim9script

if exists('g:loaded_tailwind') || &cp
  finish
endif

g:loaded_tailwind = 1

import autoload 'tailwind.vim'

nnoremap <silent> <Plug>(tailwind-lookup) :call tailwind#Lookup()<CR>

if empty(maparg('K', 'n'))
  nmap <silent> <buffer> K <Plug>(tailwind-lookup)
endif
