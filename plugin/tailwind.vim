if exists('g:loaded_tailwind') || &cp
  finish
endif

let g:loaded_tailwind = 1

nnoremap <silent> <Plug>(tailwind-lookup) :call tailwind#lookup()<CR>

if empty(maparg('K', 'n'))
  nmap <silent> <buffer> K <Plug>(tailwind-lookup)
endif
