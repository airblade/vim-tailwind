vim9script

if exists('g:loaded_tailwind') || &cp
  finish
endif

g:loaded_tailwind = 1

g:tailwind_complete_item_info = get(g:, 'tailwind_complete_item_info', v:true)
g:tailwind_complete_item_menu = get(g:, 'tailwind_complete_item_menu', v:true)
g:tailwind_complete_item_menu_length = get(g:, 'tailwind_complete_item_menu_length', 40)
g:tailwind_complete_items_max = get(g:, 'tailwind_complete_items_max', 50)

import autoload 'tailwind.vim'

nnoremap <silent> <Plug>(tailwind-lookup) :call tailwind#Lookup()<CR>

augroup tailwind
  autocmd!
  autocmd BufEnter * if empty(maparg('K', 'n')) | nmap <silent> <buffer> K <Plug>(tailwind-lookup)| endif
augroup END
