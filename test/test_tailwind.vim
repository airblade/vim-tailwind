import '../autoload/tailwind.vim'

function SetUp()
  enew
endfunction

function TearDown()
  bdelete!
endfunction


function Test_chunks()
  call assert_equal(['abc', 123, 'def'], s:tailwind.Chunks__('abc123def'))
endfunction


function Test_natural_sort()
  call assert_true(s:tailwind.NaturalSort__('p-0', 'p-0.5') < 0)
  call assert_true(s:tailwind.NaturalSort__('p-10', 'p-1') > 0)
  call assert_true(s:tailwind.NaturalSort__('p-2', 'p-10') < 0)
  call assert_true(s:tailwind.NaturalSort__('p-px', 'p-10') > 0)

  call assert_equal(
        \ ['p-1', 'p-1.5', 'p-2', 'p-2.5', 'p-10', 'p-20'],
        \ sort(['p-1', 'p-10', 'p-1.5', 'p-2', 'p-20', 'p-2.5'], s:tailwind.NaturalSort__))
endfunction


function Test_completion()
  set omnifunc=tailwind#Complete
  call setline(1, ['p-'])
  execute "normal! A\<C-X>\<C-O>\<C-N>\<C-Y>"
  call assert_equal('p-0.5', getline('.'))
endfunction


function Test_tailwind_class_at_cursor()
  call setline(1, ['<div class="p-0.5 sm:mx-auto hover:md:underline">'])

  normal! f5
  call assert_equal('p-0.5', s:tailwind.TailwindClassAtCursor__())

  normal! fs
  call assert_equal('mx-auto', s:tailwind.TailwindClassAtCursor__())

  normal! fv
  call assert_equal('underline', s:tailwind.TailwindClassAtCursor__())
endfunction
