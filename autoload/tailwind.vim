vim9script

# Key: (String) CSS (not Tailwind) class name
# Value: (List) CSS properties
var css = {}
var initialised = 0
const plugin_dir = expand('<sfile>:p:h:h')
const separator  = !exists('+shellslash') || &shellslash ? '/' : '\'


export def Lookup()
  Init()

  var css_class = TailwindToCss(TailwindClassAtCursor())
  if has_key(css, css_class)
    # TODO popup
    echom css[css_class]->join(' ')
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

  const css_prefix = TailwindToCss(base)
  for css_class in keys(css)
        ->filter((_, v) => stridx(v, css_prefix) == 0)
        ->sort(NaturalSort)
    add(matches, {
      word: CssToTailwind(css_class),
      info: css[css_class]->join("\n")
    })
  endfor

  return matches
enddef


# Ignores any variants, e.g. sm: or hover:
def TailwindClassAtCursor(): string
  return matchstr(expand('<cWORD>'), '\v[^"'':]+\ze(["''>])*$')
enddef

def CssToTailwind(name: string): string
  return substitute(name, '\', '', 'g')
enddef

def TailwindToCss(name: string): string
  return escape(name, './')
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
  initialised = 1
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

#   export def TailwindToCss__(name: string): string
#     return TailwindToCss(name)
#   enddef

#   export def CssToTailwind__(name: string): string
#     return CssToTailwind(name)
#   enddef
# endif
