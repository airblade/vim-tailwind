" Key: (String) CSS (not Tailwind) class name
" Value: (List) CSS properties
let s:css = {}
let s:initialised = 0
let s:plugin_dir = expand('<sfile>:p:h:h')
let s:separator  = !exists('+shellslash') || &shellslash ? '/' : '\'


function tailwind#lookup()
  call s:init()

  let css_class = s:tailwind_to_css(s:tailwind_class_at_cursor())
  if has_key(s:css, css_class)
    " TODO popup
    echom s:css[css_class]->join(' ')
  endif
endfunction


function tailwind#complete(findstart, base)
  call s:init()

  if a:findstart
    let line = getline('.')
    let start = col('.') - 1

    while start > 0 && line[start - 1] =~ '[0-9A-Za-z._-]'
      let start -= 1
    endwhile

    return start
  end

  let matches = []

  for css_class in keys(s:css)
        \ ->filter({_, v -> stridx(s:css_to_tailwind(v), a:base) == 0})
        \ ->sort('s:natural_sort')
    call add(matches, {
          \  'word': s:css_to_tailwind(css_class),
          \  'info': join(s:css[css_class], "\n")
          \ })
  endfor

  return matches
endfunction


" Ignores any variants, e.g. sm: or hover:
function s:tailwind_class_at_cursor()
  return matchstr(expand('<cWORD>'), '\v[^"'':]+\ze(["''>])*$')
endfunction

function s:css_to_tailwind(str)
  return substitute(a:str, '\', '', 'g')
endfunction

function s:tailwind_to_css(str)
  return escape(a:str, './')
endfunction

function s:natural_sort(a, b)
  let chunks_a = s:chunks(a:a)
  let chunks_b = s:chunks(a:b)
  " Compare as many chunks as possible
  " and return 1 or -1 if any are not equal.
  for i in range(min([len(chunks_a), len(chunks_b)]))
    let [chunk_a, chunk_b] = [chunks_a[i], chunks_b[i]]
    if type(chunk_a) == type(chunk_b)
      if chunk_a <# chunk_b
        return -1
      elseif chunk_a ># chunk_b
        return 1
      endif
    elseif type(chunk_a) == v:t_number
      return -1
    elseif type(chunk_b) == v:t_number
      return 1
    endif
  endfor

  " The chunks are identical so far.
  " The key which has fewer chunks is the lesser one.
  return len(chunks_a) - len(chunks_b)
endfunction

" Split text into a list of strings and numbers.
"
" E.g. 'abc123def' -> ['abc', 123, 'def']
function s:chunks(text)
  let chunks = split(a:text, '\v(\D+|\d+)\zs')
  let i = 0
  for chunk in chunks
    if chunk =~ '^\d\+$'
      let chunks[i] = str2nr(chunk)
    endif
    let i += 1
  endfor
  return chunks
endfunction

function s:init()
  if s:initialised | return | endif
  let s:css = readfile(s:plugin_dir.s:separator.'output.json')
        \ ->join('')
        \ ->json_decode()
  let s:initialised = 1
endfunction
