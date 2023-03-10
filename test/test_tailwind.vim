function SetUp()
  enew
  " Nudge the autoloader.
  call tailwind#lookup()
endfunction

function TearDown()
  bdelete!
endfunction

function s:script_local_function(path, name)
  let sid = matchstr(execute('filter '.a:path.' scriptnames'), '\d\+')
  return function("<SNR>".sid."_".a:name)
endfunction


function Test_css_to_tailwind()
  let F = s:script_local_function('autoload/tailwind.vim', 'css_to_tailwind')

  call assert_equal('foo',         call(F, ['foo']))
  call assert_equal('p-2.5',       call(F, ['p-2\.5']))
  call assert_equal('inset-y-3/5', call(F, ['inset-y-3\/5']))
endfunction


function Test_tailwind_to_css()
  let F = s:script_local_function('autoload/tailwind.vim', 'tailwind_to_css')

  call assert_equal('foo',          call(F, ['foo']))
  call assert_equal('p-2\.5',       call(F, ['p-2.5']))
  call assert_equal('inset-y-3\/5', call(F, ['inset-y-3/5']))
endfunction


function Test_chunks()
  let F = s:script_local_function('autoload/tailwind.vim', 'chunks')

  call assert_equal(['abc', 123, 'def'], call(F, ['abc123def']))
endfunction


function Test_natural_sort()
  let F = s:script_local_function('autoload/tailwind.vim', 'natural_sort')

  call assert_true(call(F, ['p-0',  'p-0.5']) < 0)
  call assert_true(call(F, ['p-10', 'p-1'])   > 0)
  call assert_true(call(F, ['p-2',  'p-10'])  < 0)
  call assert_true(call(F, ['p-px', 'p-10'])  > 0)

  call assert_equal(['p-1', 'p-1.5', 'p-2', 'p-2.5', 'p-10', 'p-20'],
        \ sort(['p-1', 'p-10', 'p-1.5', 'p-2', 'p-20', 'p-2.5'], F))
endfunction


function Test_completion()
  set omnifunc=tailwind#complete
  call setline(1, ['p-'])
  execute "normal! A\<C-X>\<C-O>\<C-N>\<C-Y>"
  call assert_equal('p-0.5', getline('.'))
endfunction


function Test_tailwind_class_at_cursor()
  let Class = s:script_local_function('autoload/tailwind.vim', 'tailwind_class_at_cursor')

  call setline(1, ['<div class="p-0.5 sm:mx-auto hover:md:underline">'])

  normal! f5
  call assert_equal('p-0.5', call(Class, []))

  normal! fs
  call assert_equal('mx-auto', call(Class, []))

  normal! fv
  call assert_equal('underline', call(Class, []))
endfunction
