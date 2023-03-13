vim9script

# Key: Tailwind class name
# Value: CSS properties
var css: dict<list<string>>
var initialised: bool
const plugin_dir = expand('<sfile>:p:h:h')
const separator  = !exists('+shellslash') || &shellslash ? '/' : '\'


export def Lookup()
  Init()

  var name = TailwindClassAtCursor()
  if has_key(css, name)
    # TODO popup
    echom css[name]->join(' ')
  endif
enddef


export def Complete(findstart: number, base: string): any
  Init()

  if findstart
    var line = getline('.')
    var start = col('.') - 1

    while start > 0 && line[start - 1] =~ '[0-9A-Za-z._-]'
      start -= 1
    endwhile

    return start
  endif

  var matches = []

  for name in keys(css)
        ->filter((_, v) => stridx(v, base) == 0)
        ->sort(NaturalSort)
    var item = { word: name }
    if g:tailwind_complete_item_info
      item.info = css[name]->join("\n")
    endif
    if g:tailwind_complete_item_menu
      const property = css[name]->join()
      item.menu = strwidth(property) > g:tailwind_complete_item_menu_length
        ? property[ : g:tailwind_complete_item_menu_length - 3] .. '...'
        : property
    endif
    add(matches, item)
  endfor

  return matches
enddef


# Ignores any variants, e.g. sm: or hover:
def TailwindClassAtCursor(): string
  return matchstr(expand('<cWORD>'), '\v[^"'':]+\ze(["''>])*$')
enddef

def NaturalSort(a: string, b: string): number
  var chunks_a = Chunks(a)
  var chunks_b = Chunks(b)
  # Compare as many chunks as possible
  # and return 1 or -1 if any are not equal.
  for i in range(min([len(chunks_a), len(chunks_b)]))
    var [chunk_a, chunk_b] = [chunks_a[i], chunks_b[i]]
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

  # The chunks are identical so far.
  # The key which has fewer chunks is the lesser one.
  return len(chunks_a) - len(chunks_b)
enddef

# Split text into a list of strings and numbers.
#
# E.g. 'abc123def' -> ['abc', 123, 'def']
def Chunks(text: string): list<any>
  return split(text, '\v(\D+|\d+)\zs')
        ->map((_, v) => v =~ '^\d\+$' ? str2nr(v) : v)
enddef

def Init()
  if initialised | return | endif
  css = readfile(plugin_dir .. separator .. 'output.json')
        ->join('')
        ->json_decode()
  initialised = v:true
enddef


# For some reason this errors when $TEST is not set
# (which is in normal operation).
#
# if exists("$TEST")
#   export def TailwindClassAtCursor__(): string
#     return TailwindClassAtCursor()
#   enddef

#   export def NaturalSort__(a: string, b: string): number
#     return NaturalSort(a, b)
#   enddef

#   export def Chunks__(text: string): list<any>
#     return Chunks(text)
#   enddef
# endif
