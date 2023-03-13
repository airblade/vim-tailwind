# vim-tailwind

A Vim plugin to autocomplete Tailwind class names without LSP.

It also lets you look up a Tailwind class's CSS properties.


## Tailwind version

v3.2.7


## Installation

Install like every other Vim plugin :)


## Usage

### Autocompletion

For user-defined autocompletion (via `<C-X><C-U>`):

```vim
setlocal completefunc=tailwind#Complete
```

Or for omnicompletion (via `<C-X><C-O>`):

```vim
setlocal omnifunc=tailwind#Complete
```

I have the following snippet in my vimrc to set this up:

```vim
function! s:is_tailwind()
  return !empty(findfile('tailwind.config.js', '.;'))
endfunction

autocmd BufEnter *.html,*.slim if s:is_tailwind() |
      \   setlocal omnifunc=tailwind#Complete |
      \ endif
```

### Lookup

Unless you have `K` mapped already, press `K` in normal mode with your cursor on a Tailwind class.

To map some other key, e.g. `gk`:

```vim
nmap <silent> <buffer> gk <Plug>(tailwind-lookup)
```


## Caveats

The plugin ignores modifiers, e.g. `sm:` or `hover:`.  They affect when the CSS is applied, not what the CSS actually is, so they are irrelevant here.

The plugin ignores `@media` at-rules.  This only affects the [`.container`](https://tailwindcss.com/docs/container) class.


## Intellectual property

Copyright Andrew Stewart.  Released under the MIT licence.
